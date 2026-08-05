-- ============================================================================
-- 卡牌资产 App — Supabase 后台一键初始化脚本
--
-- 使用方式：Supabase 控制台 → 左侧 SQL Editor → New query → 粘贴全文 → Run。
-- 项目：https://tnayodtcpaetkcyrjuye.supabase.co
--
-- 脚本做三件事：
--   1. 建 public.cards 表（卡牌增量同步的目标表）
--   2. 建 user-backups 存储桶（整库文件备份的目标桶）
--   3. 配置 RLS 策略，允许 App 使用 publishable(anon) 密钥读写
--
-- 全部语句幂等，可重复执行。
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. 卡牌表：列名与 lib/.../supabase_card_sync.dart 的 _toRemoteJson 一一对应
-- ----------------------------------------------------------------------------
create table if not exists public.cards (
  id                  text primary key,
  user_id             text not null default 'local-user',
  catalog_id          text not null default '',
  name                text not null default '',
  card_number         text not null default '',
  image_url           text not null default '',
  grading             text not null default 'raw',
  category            text not null default 'all',
  grade_score         double precision,
  cert_number         text,
  buy_price           double precision not null default 0,
  market_price        double precision not null default 0,
  buy_date            timestamptz,
  is_collected        boolean not null default true,
  volume              double precision not null default 0,
  is_wishlist         boolean not null default false,
  target_price        double precision,
  wishlist_priority   integer not null default 0,
  price_history_json  text not null default '',
  centering_data      text,
  image_paths         text not null default '[]',
  created_at          timestamptz not null default now()
);

create index if not exists cards_user_id_idx on public.cards (user_id);

alter table public.cards enable row level security;

-- App 当前无登录体系（仅用 publishable anon 密钥），故放开 anon 读写。
-- 客户端从 H-1 起为每台设备安装一个 RFC4122 v4 设备 UUID，作为 user_id 写入，
-- 提供「命名空间隔离」：不同设备的同步/备份数据互不覆盖、可按 user_id 客户端过滤。
-- 注意：anon 密钥下服务端无法强制「只见自己设备行」，如需服务端行级安全隔离，
-- 须接入 Supabase Auth，并把下面策略改为 using (auth.uid()::text = user_id)。
drop policy if exists "anon full access on cards" on public.cards;
create policy "anon full access on cards"
  on public.cards
  for all
  to anon, authenticated
  using (true)
  with check (true);


-- ----------------------------------------------------------------------------
-- 2. 备份存储桶：整库 .isar 快照上传目标（私有桶）
-- ----------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('user-backups', 'user-backups', false)
on conflict (id) do nothing;


-- ----------------------------------------------------------------------------
-- 3. 存储桶 RLS：允许 anon 对 user-backups 增删改查
--    （upsert 覆盖备份需要 insert + update + select 三项权限）
-- ----------------------------------------------------------------------------
drop policy if exists "anon read user-backups"   on storage.objects;
drop policy if exists "anon insert user-backups" on storage.objects;
drop policy if exists "anon update user-backups" on storage.objects;
drop policy if exists "anon delete user-backups" on storage.objects;

create policy "anon read user-backups"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'user-backups');

create policy "anon insert user-backups"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'user-backups');

create policy "anon update user-backups"
  on storage.objects for update
  to anon, authenticated
  using (bucket_id = 'user-backups')
  with check (bucket_id = 'user-backups');

create policy "anon delete user-backups"
  on storage.objects for delete
  to anon, authenticated
  using (bucket_id = 'user-backups');


-- ----------------------------------------------------------------------------
-- 4. 公共主图鉴表：UGC 众包卡牌元数据的共享目标表
-- ----------------------------------------------------------------------------
create table if not exists public.master_catalogs (
  id           text primary key,                         -- 标准化主图鉴 ID：category_set_cardnumber
  category     text not null default '',
  set_name     text not null default '',
  card_number  text not null default '',
  name         text not null default '',
  image_url    text not null default '',
  grading      text not null default 'raw',
  status       text not null default 'community',       -- 'community' | 'verified'
  contributed_by text not null default 'local-user',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists master_catalogs_category_idx on public.master_catalogs (category);

-- 严格身份唯一约束（任务二）：从物理层彻底杜绝众包重复与污染数据。
-- 维度 = 语言(language) / 系列(set_name) / 类型(category) / 序号(card_number) / 名称(name)，
-- 五维一致即视为同一张卡，重复上报将被唯一约束拦截（客户端以 23505 冲突优雅回退）。
-- 复合唯一约束会自动生成对应的唯一 B-Tree 索引，无需再单独建索引。
alter table public.master_catalogs
  add column if not exists language text not null default 'en';

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'unique_card_strict_identity'
  ) then
    alter table public.master_catalogs
      add constraint unique_card_strict_identity
      unique (language, set_name, category, card_number, name);
  end if;
end $$;

alter table public.master_catalogs enable row level security;

-- anon 可插入社区条目（status 强制为合法值）。
drop policy if exists "anon insert master_catalogs" on public.master_catalogs;
create policy "anon insert master_catalogs"
  on public.master_catalogs for insert
  to anon, authenticated
  with check (status = 'community' or status = 'verified');

-- anon 可读取全部主图鉴（社区共建需可见）。
drop policy if exists "anon read master_catalogs" on public.master_catalogs;
create policy "anon read master_catalogs"
  on public.master_catalogs for select
  to anon, authenticated
  using (true);

-- anon 仅可更新「社区」条目：官方 verified 数据由服务器/管理员维护，客户端改不动。
drop policy if exists "anon update master_catalogs" on public.master_catalogs;
create policy "anon update master_catalogs"
  on public.master_catalogs for update
  to anon, authenticated
  using (status = 'community')
  with check (true);


-- ----------------------------------------------------------------------------
-- 5. 公共卡面图片桶：用户上传的本地卡面图统一公共化，供主图鉴引用
-- ----------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('catalog_images', 'catalog_images', true)        -- public=true：图片可被任何人只读访问
on conflict (id) do nothing;

drop policy if exists "anon read catalog_images"   on storage.objects;
drop policy if exists "anon insert catalog_images" on storage.objects;
drop policy if exists "anon update catalog_images" on storage.objects;
drop policy if exists "anon delete catalog_images" on storage.objects;

create policy "anon read catalog_images"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'catalog_images');

create policy "anon insert catalog_images"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'catalog_images');

create policy "anon update catalog_images"
  on storage.objects for update
  to anon, authenticated
  using (bucket_id = 'catalog_images')
  with check (bucket_id = 'catalog_images');

create policy "anon delete catalog_images"
  on storage.objects for delete
  to anon, authenticated
  using (bucket_id = 'catalog_images');


-- ----------------------------------------------------------------------------
-- 6. 验证：执行后应看到 cards / master_catalogs 表与 user-backups / catalog_images 桶各返回一行
-- ----------------------------------------------------------------------------
select 'table' as kind, table_name as name
  from information_schema.tables
 where table_schema = 'public' and table_name in ('cards', 'master_catalogs')
union all
select 'bucket' as kind, id as name
  from storage.buckets
 where id in ('user-backups', 'catalog_images');
