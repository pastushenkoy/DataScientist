select
    date_part('day', fpd.first_payment_date - u.created_at) days_between_sign_up_and_payment,
    count(u.id) count
from
    users u
    inner join (
        select
            carts.user_id user_id,
            min(payment_transactions.created_at) first_payment_date
        from
            carts
            join payment_transactions
            on carts.Id = payment_transactions.cart_id
        group by
            carts.user_id
    ) fpd
    on u.id = fpd.user_id
    left join lead_requests lreq
    on u.id = lreq.user_id
where
    u.created_at >= '2017-01-01'
    and lreq.user_id is null
group by
    date_part('day', fpd.first_payment_date - u.created_at)
order by
    days_between_sign_up_and_payment