select
    extract(epoch from date_trunc('month', u.created_at)) reg_month,
    count(u.id) count
from
    users u
group by
    date_trunc('month', u.created_at)
