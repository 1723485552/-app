-- ============================================================================
-- 修复：补齐 master_catalogs 所有缺失列 + 建唯一约束
--
-- 背景：当前表只有 6 列（ID/创建于/类别/设置名称/卡号/图片网址），
--       缺少 name/grading/status/contributed_by/updated_at/language 共 7 列。
--       唯一约束引用了 name + language，故 42703 报错。
--
-- 使用方式：Supabase 控制台 → SQL Editor → 清空 → 粘贴全文 → Run
-- 幂等设计：重复执行不会报错。
-- ============================================================================


-- ════════════════════════════════════════════════════════════
-- 第 1 步：补齐所有缺失列（每条 ADD COLUMN 都是幂等的）
-- ════════════════════════════════════════════════════════════

alter table public.master_catalogs
  add column if not exists name         text not null default '';

alter table public.master_catalogs
  add column if not exists grading      text not null default 'raw';

alter table public.master_catalogs
  add column if not exists status       text not null default 'community';

alter table public.master_catalogs
  add column if not exists contributed_by text not null default 'local-user';

alter table public.master_catalogs
  add column if not exists updated_at   timestamptz not null default now();

alter table public.master_catalogs
  add column if not exists language     text not null default 'en';


-- ════════════════════════════════════════════════════════════
-- 第 2 步：幂等建复合唯一约束
-- ════════════════════════════════════════════════════════════
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'unique_card_strict_identity'
  ) then
    alter table public.master_catalogs
      add constraint unique_card_strict_identity
      unique (language, set_name, category, card_number, name);
    raise notice '✅ 唯一约束已创建';
  else
    raise notice 'ℹ️  约束已存在，跳过';
  end if;
end $$;


-- ════════════════════════════════════════════════════════════
-- 第 3 步：验证 —— 应显示 13 列 + 1 条约束记录
-- ════════════════════════════════════════════════════════════

select '=== 列数 ===' as info, count(*)::text as value
  from information_schema.columns
 where table_schema = 'public' and table_name = 'master_catalogs'
union all
select '=== 约束 ===', coalesce(conname, '(无)')
  from pg_constraint
 where conname = 'unique_card_strict_identity'
   and conrelid = 'public.master_catalogs'::regclass;
