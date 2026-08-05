-- ============================================================================
-- 诊断 + 修复：master_catalogs 表结构与唯一约束
--
-- 使用方式：Supabase 控制台 → SQL Editor → 清空编辑器 → 粘贴全文 → Run
-- ============================================================================


-- ── 第 1 步：诊断 —— 看 master_catalogs 表当前实际有哪些列 ──
select column_name, data_type, is_nullable, column_default
  from information_schema.columns
 where table_schema = 'public'
   and table_name = 'master_catalogs'
 order by ordinal_position;


-- ── 第 2 步：补齐可能缺失的列（每条都是幂等的） ──

-- language 列（任务二新增，旧版表可能没有）
alter table public.master_catalogs
  add column if not exists language text not null default 'en';


-- ── 第 3 步：幂等建唯一约束 ──
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'unique_card_strict_identity'
  ) then
    alter table public.master_catalogs
      add constraint unique_card_strict_identity
      unique (language, set_name, category, card_number, name);
    raise notice '✅ 唯一约束 unique_card_strict_identity 已创建';
  else
    raise notice 'ℹ️  唯一约束已存在，跳过';
  end if;
exception
  when others then
    raise notice '❌ 创建约束失败: %', sqlerrm;
end $$;


-- ── 第 4 步：最终验证 ──
select conname as constraint_name,
       pg_get_constraintdef(oid) as definition
  from pg_constraint
 where conname = 'unique_card_strict_identity'
   and conrelid = 'public.master_catalogs'::regclass;
