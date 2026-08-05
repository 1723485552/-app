-- ============================================================================
-- 修复脚本：补齐 master_catalogs.language 列 + 建复合唯一约束
--
-- 使用方式：Supabase 控制台 → SQL Editor → 粘贴本文件全文 → Run
-- 项目：https://tnayodtcpaetkcyrjuye.supabase.co
--
-- 本脚本幂等，可重复执行不会报错。
-- ============================================================================


-- 步骤 1：确保 language 列存在（旧版表可能缺此列）
alter table public.master_catalogs
  add column if not exists language text not null default 'en';


-- 步骤 2：幂等添加复合唯一约束（五维防重）
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


-- 步骤 3：验证 —— 应返回一行，constraint_name = unique_card_strict_identity
select conname as constraint_name,
       pg_get_constraintdef(oid) as definition
  from pg_constraint
 where conname = 'unique_card_strict_identity'
   and conrelid = 'public.master_catalogs'::regclass;
