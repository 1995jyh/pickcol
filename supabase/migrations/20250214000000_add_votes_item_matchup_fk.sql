-- 1) matchup_items에 (id, matchup_id) 유니크 추가
-- votes의 (item_id, matchup_id) 복합 FK가 참조할 수 있게 함
alter table public.matchup_items
  add constraint matchup_items_id_matchup_id_uniq unique (id, matchup_id);

-- 2) votes에 (item_id, matchup_id) 복합 FK 추가
-- "해당 매치업의 항목에만 투표" 강제
alter table public.votes
  add constraint votes_item_matchup_fk
  foreign key (item_id, matchup_id)
  references public.matchup_items (id, matchup_id)
  on delete cascade;
