select
    msg.name,
    count(u.id) count
from
    users u
    left join marketing_sources ms
        join marketing_source_groups msg
        on ms.source_group_id = msg.id
    on u.marketing_source_id = ms.id
    left join lead_requests lreq
    on u.id = lreq.user_id
where
    u.created_at >= '2017-01-01'
    and lreq.user_id is null
    --and ms.source_group_id is not null
group by
    msg.name
order by
    count desc
