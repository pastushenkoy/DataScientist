select
    -- ИДЕНТИФИКАТОР
    u.id user_id,
	
	-- ПОЛЯ ДЛЯ АНАЛИЗА
	u.first_name first_name,
    extract(epoch from u.created_at) sign_up_date,
    fpd.first_payment_date,
	
    -- ПОЛЕ ДЛЯ ФОРМИРОВАНИЯ ЦЕЛЕВОЙ ПЕРЕМЕННОЙ
    date_part('day', fpd.first_payment_date - u.created_at) paid_on_day_since_sign_up,
    
    
    -- ФИЧИ
    -- Регистрационный реферер
    ui.registration_data->'referer' reg_page,
    ui.registration_data->'user_agent' user_agent,
    -- Анкетка при регистрации
    ui.intro_test->'reason' reason,
    ui.intro_test->'teacher' teacher,
    ui.intro_test->'time' "time",
    ui.intro_test->'best_statement' best_statement,
    
    -- Дата регистрации
    case
        when date_part('dow', u.created_at) = 0 or date_part('dow', u.created_at) = 6
            then 1
        else 0
    end signed_up_on_weekend_day,
    case
        when date_part('hour', u.created_at) >= 0 and date_part('hour', u.created_at) <= 7
            then 1
        else 0
    end signed_up_at_night_interval,
    
    -- Группа маркетинговых источников
    ms.source_group_id source_group_id,
    
    -- Класс ученика
    u.grade_id grade_id,
    
    -- Заполнена ли дата рождения
    case
        when u.birthday is null
            then 0
        else 1
    end has_birth_date,
    -- Является родителем
    cast(u.parent as int) is_parent,
    -- Является учителем
    cast(u.is_teacher as int) is_teacher,
    -- Ввел телефон
    case
        when u.phone is null
            then 0
        else 1
    end has_phone,
    cast(u.phone_confirmed as int) phone_confirmed,
    -- Адресные данные
    case
        when a.id is null or a.created_at > fpd.first_payment_date
            then 0
        else 1
    end address_entered_before_payment,
    cast(c.region_id as int) region_id,
    -- Школа
    u.school_id

from
    users u
    left join user_infos ui
    on u.id = ui.user_id
    -- Дата первой оплаты
    left join (
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
    -- Группы маркетинговых источников
    left join marketing_sources ms
    on u.marketing_source_id = ms.id
    -- Адреса
    left join addresses a
        left join cities c
        on a.city_id = c.id
    on u.id = a.addressable_id
    -- Заявки на звонок
    left join lead_requests lreq
    on u.id = lreq.user_id
where
    u.created_at >= '20170101'
    and lreq.user_id is null

