select
    ui.registration_data->'referer' reg_page,
    count(u.id) count
from
    users u
    join user_infos ui
    on u.id = ui.user_id
    left join lead_requests lreq
    on u.id = lreq.user_id
where
    u.created_at >= '2017-01-01'
    and lreq.user_id is null
group by
    ui.registration_data->'referer'
order by
    count desc