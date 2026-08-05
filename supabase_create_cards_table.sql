-- ============================================================
-- 最小修复：只建 cards 表（幂等，重复跑不报错）
-- 用途：之前 supabase_setup.sql 因约束报错 42703 中断，
--       整条脚本事务回滚导致 cards 表未创建。
-- ============================================================

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

drop policy if exists "anon full access on cards" on public.cards;
create policy "anon full access on cards"
  on public.cards for all to anon, authenticated using (true) with check (true);

-- 验证
select 'cards' as table_name, count(*) as column_count from information_schema.columns where table_schema = 'public' and table_name = 'cards';
