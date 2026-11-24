--
-- PostgreSQL database dump
--

\restrict W66XC3UqB6cEcuT3KtaG6aAGu564gPceXDdaSfbb2KNerh5m0rCXuVHWsqw4JPq

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.user_season_stats DROP CONSTRAINT IF EXISTS user_season_stats_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_season_stats DROP CONSTRAINT IF EXISTS user_season_stats_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_template_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_templates DROP CONSTRAINT IF EXISTS tournament_templates_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_entries DROP CONSTRAINT IF EXISTS tournament_entries_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tournament_entries DROP CONSTRAINT IF EXISTS tournament_entries_tournament_id_fkey;
ALTER TABLE IF EXISTS ONLY public.point_transactions DROP CONSTRAINT IF EXISTS point_transactions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.point_transactions DROP CONSTRAINT IF EXISTS point_transactions_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.manual_rewards DROP CONSTRAINT IF EXISTS manual_rewards_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.manual_rewards DROP CONSTRAINT IF EXISTS manual_rewards_tournament_id_fkey;
ALTER TABLE IF EXISTS ONLY public.drops DROP CONSTRAINT IF EXISTS drops_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.drops DROP CONSTRAINT IF EXISTS drops_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.drops DROP CONSTRAINT IF EXISTS drops_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.drops DROP CONSTRAINT IF EXISTS drops_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_season_id_fkey;
ALTER TABLE IF EXISTS ONLY public.case_items DROP CONSTRAINT IF EXISTS case_items_case_id_fkey;
ALTER TABLE IF EXISTS ONLY public.activity_reward_config DROP CONSTRAINT IF EXISTS activity_reward_config_season_id_fkey;
DROP INDEX IF EXISTS public.ix_user_season_stats_user_id;
DROP INDEX IF EXISTS public.ix_user_season_stats_season_id;
DROP INDEX IF EXISTS public.ix_tournaments_season_id;
DROP INDEX IF EXISTS public.ix_tournament_templates_season_id;
DROP INDEX IF EXISTS public.ix_tournament_entries_user_id;
DROP INDEX IF EXISTS public.ix_tournament_entries_tournament_id;
DROP INDEX IF EXISTS public.ix_point_transactions_user_id;
DROP INDEX IF EXISTS public.ix_point_transactions_season_id;
DROP INDEX IF EXISTS public.ix_point_transactions_created_at;
DROP INDEX IF EXISTS public.ix_drops_user_id;
DROP INDEX IF EXISTS public.ix_drops_season_id;
DROP INDEX IF EXISTS public.ix_drops_rolled_at;
DROP INDEX IF EXISTS public.ix_cases_season_id;
DROP INDEX IF EXISTS public.ix_case_items_case_id;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.user_season_stats DROP CONSTRAINT IF EXISTS user_season_stats_pkey;
ALTER TABLE IF EXISTS ONLY public.user_season_stats DROP CONSTRAINT IF EXISTS uq_season_user;
ALTER TABLE IF EXISTS ONLY public.tournaments DROP CONSTRAINT IF EXISTS tournaments_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_templates DROP CONSTRAINT IF EXISTS tournament_templates_pkey;
ALTER TABLE IF EXISTS ONLY public.tournament_entries DROP CONSTRAINT IF EXISTS tournament_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.seasons DROP CONSTRAINT IF EXISTS seasons_pkey;
ALTER TABLE IF EXISTS ONLY public.point_transactions DROP CONSTRAINT IF EXISTS point_transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.manual_rewards DROP CONSTRAINT IF EXISTS manual_rewards_pkey;
ALTER TABLE IF EXISTS ONLY public.drops DROP CONSTRAINT IF EXISTS drops_pkey;
ALTER TABLE IF EXISTS ONLY public.cases DROP CONSTRAINT IF EXISTS cases_pkey;
ALTER TABLE IF EXISTS ONLY public.case_items DROP CONSTRAINT IF EXISTS case_items_pkey;
ALTER TABLE IF EXISTS ONLY public.activity_reward_config DROP CONSTRAINT IF EXISTS activity_reward_config_season_id_key;
ALTER TABLE IF EXISTS ONLY public.activity_reward_config DROP CONSTRAINT IF EXISTS activity_reward_config_pkey;
ALTER TABLE IF EXISTS public.user_season_stats ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournaments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_templates ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.tournament_entries ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.seasons ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.point_transactions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.manual_rewards ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.drops ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cases ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.case_items ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.activity_reward_config ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.user_season_stats_id_seq;
DROP TABLE IF EXISTS public.user_season_stats;
DROP SEQUENCE IF EXISTS public.tournaments_id_seq;
DROP TABLE IF EXISTS public.tournaments;
DROP SEQUENCE IF EXISTS public.tournament_templates_id_seq;
DROP TABLE IF EXISTS public.tournament_templates;
DROP SEQUENCE IF EXISTS public.tournament_entries_id_seq;
DROP TABLE IF EXISTS public.tournament_entries;
DROP SEQUENCE IF EXISTS public.seasons_id_seq;
DROP TABLE IF EXISTS public.seasons;
DROP SEQUENCE IF EXISTS public.point_transactions_id_seq;
DROP TABLE IF EXISTS public.point_transactions;
DROP SEQUENCE IF EXISTS public.manual_rewards_id_seq;
DROP TABLE IF EXISTS public.manual_rewards;
DROP SEQUENCE IF EXISTS public.drops_id_seq;
DROP TABLE IF EXISTS public.drops;
DROP SEQUENCE IF EXISTS public.cases_id_seq;
DROP TABLE IF EXISTS public.cases;
DROP SEQUENCE IF EXISTS public.case_items_id_seq;
DROP TABLE IF EXISTS public.case_items;
DROP SEQUENCE IF EXISTS public.activity_reward_config_id_seq;
DROP TABLE IF EXISTS public.activity_reward_config;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_reward_config; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.activity_reward_config (
    id integer NOT NULL,
    season_id integer NOT NULL,
    points_comment integer NOT NULL,
    points_subscription integer NOT NULL,
    points_referral integer NOT NULL,
    daily_limit_comment integer NOT NULL,
    min_comment_length integer NOT NULL,
    comment_cooldown_seconds integer NOT NULL,
    block_duplicate_comments boolean NOT NULL,
    referral_requires_action boolean NOT NULL,
    quality_weight_fn integer DEFAULT 10,
    quality_weight_mw integer DEFAULT 20,
    quality_weight_ft integer DEFAULT 50,
    quality_weight_ww integer DEFAULT 15,
    quality_weight_bs integer DEFAULT 5,
    mult_fn double precision DEFAULT 1.45,
    mult_mw double precision DEFAULT 1.15,
    mult_ft double precision DEFAULT 0.85,
    mult_ww double precision DEFAULT 0.65,
    mult_bs double precision DEFAULT 0.5,
    stattrak_chance integer DEFAULT 10,
    stattrak_multiplier double precision DEFAULT 2.0
);


ALTER TABLE public.activity_reward_config OWNER TO casebot;

--
-- Name: activity_reward_config_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.activity_reward_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activity_reward_config_id_seq OWNER TO casebot;

--
-- Name: activity_reward_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.activity_reward_config_id_seq OWNED BY public.activity_reward_config.id;


--
-- Name: case_items; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.case_items (
    id integer NOT NULL,
    case_id integer NOT NULL,
    name character varying(64) NOT NULL,
    rarity character varying(16) NOT NULL,
    weight integer NOT NULL,
    quality_score integer NOT NULL,
    point_value integer NOT NULL,
    deleted_at timestamp with time zone,
    image_url character varying(255)
);


ALTER TABLE public.case_items OWNER TO casebot;

--
-- Name: case_items_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.case_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.case_items_id_seq OWNER TO casebot;

--
-- Name: case_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.case_items_id_seq OWNED BY public.case_items.id;


--
-- Name: cases; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.cases (
    id integer NOT NULL,
    season_id integer NOT NULL,
    name character varying(64) NOT NULL,
    price_points integer NOT NULL,
    is_active boolean NOT NULL,
    created_by bigint,
    image_url character varying(255)
);


ALTER TABLE public.cases OWNER TO casebot;

--
-- Name: cases_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cases_id_seq OWNER TO casebot;

--
-- Name: cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.cases_id_seq OWNED BY public.cases.id;


--
-- Name: drops; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.drops (
    id bigint NOT NULL,
    season_id integer NOT NULL,
    user_id bigint NOT NULL,
    case_id integer NOT NULL,
    item_id integer NOT NULL,
    rolled_at timestamp with time zone DEFAULT now() NOT NULL,
    float_value double precision,
    quality character varying(2),
    is_stattrak boolean DEFAULT false,
    final_price integer,
    is_sold boolean DEFAULT false
);


ALTER TABLE public.drops OWNER TO casebot;

--
-- Name: drops_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.drops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drops_id_seq OWNER TO casebot;

--
-- Name: drops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.drops_id_seq OWNED BY public.drops.id;


--
-- Name: manual_rewards; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.manual_rewards (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    tournament_id integer,
    description text NOT NULL,
    status character varying(16) NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    given_at timestamp with time zone
);


ALTER TABLE public.manual_rewards OWNER TO casebot;

--
-- Name: manual_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.manual_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.manual_rewards_id_seq OWNER TO casebot;

--
-- Name: manual_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.manual_rewards_id_seq OWNED BY public.manual_rewards.id;


--
-- Name: point_transactions; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.point_transactions (
    id bigint NOT NULL,
    season_id integer NOT NULL,
    user_id bigint NOT NULL,
    amount integer NOT NULL,
    source character varying(32) NOT NULL,
    meta jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.point_transactions OWNER TO casebot;

--
-- Name: point_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.point_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.point_transactions_id_seq OWNER TO casebot;

--
-- Name: point_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.point_transactions_id_seq OWNED BY public.point_transactions.id;


--
-- Name: seasons; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.seasons (
    id integer NOT NULL,
    chat_id bigint NOT NULL,
    name character varying(128) NOT NULL,
    status character varying(16) NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    rules_text text,
    rules_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.seasons OWNER TO casebot;

--
-- Name: seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.seasons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seasons_id_seq OWNER TO casebot;

--
-- Name: seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.seasons_id_seq OWNED BY public.seasons.id;


--
-- Name: tournament_entries; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.tournament_entries (
    id bigint NOT NULL,
    tournament_id integer NOT NULL,
    user_id bigint NOT NULL,
    total_score bigint NOT NULL,
    rank integer,
    reward_given boolean NOT NULL
);


ALTER TABLE public.tournament_entries OWNER TO casebot;

--
-- Name: tournament_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.tournament_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_entries_id_seq OWNER TO casebot;

--
-- Name: tournament_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.tournament_entries_id_seq OWNED BY public.tournament_entries.id;


--
-- Name: tournament_templates; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.tournament_templates (
    id integer NOT NULL,
    season_id integer NOT NULL,
    name character varying(64) NOT NULL,
    type character varying(16) NOT NULL,
    duration_hours integer NOT NULL,
    top_n integer NOT NULL,
    min_score integer NOT NULL,
    score_multiplier jsonb NOT NULL,
    reward_config jsonb NOT NULL,
    is_active boolean NOT NULL,
    cron_expression character varying(64),
    next_start_at timestamp with time zone,
    is_recurring boolean DEFAULT true NOT NULL,
    display_limit integer DEFAULT 10 NOT NULL,
    leaderboard_labels jsonb DEFAULT '{}'::jsonb,
    nickname_max_length integer DEFAULT 15
);


ALTER TABLE public.tournament_templates OWNER TO casebot;

--
-- Name: tournament_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.tournament_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_templates_id_seq OWNER TO casebot;

--
-- Name: tournament_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.tournament_templates_id_seq OWNED BY public.tournament_templates.id;


--
-- Name: tournaments; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.tournaments (
    id integer NOT NULL,
    template_id integer,
    season_id integer NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status character varying(16) NOT NULL,
    finalized_at timestamp with time zone,
    name character varying(64) DEFAULT 'Турнир'::character varying NOT NULL,
    top_n integer DEFAULT 10,
    min_score integer DEFAULT 0,
    score_multiplier jsonb DEFAULT '{}'::jsonb,
    reward_config jsonb DEFAULT '{}'::jsonb,
    display_limit integer DEFAULT 10 NOT NULL,
    leaderboard_labels jsonb DEFAULT '{}'::jsonb,
    nickname_max_length integer DEFAULT 15
);


ALTER TABLE public.tournaments OWNER TO casebot;

--
-- Name: tournaments_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.tournaments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournaments_id_seq OWNER TO casebot;

--
-- Name: tournaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.tournaments_id_seq OWNED BY public.tournaments.id;


--
-- Name: user_season_stats; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.user_season_stats (
    id bigint NOT NULL,
    season_id integer NOT NULL,
    user_id bigint NOT NULL,
    points_balance bigint NOT NULL,
    streak_days integer NOT NULL,
    last_daily_at timestamp with time zone,
    total_quality_score bigint NOT NULL
);


ALTER TABLE public.user_season_stats OWNER TO casebot;

--
-- Name: user_season_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: casebot
--

CREATE SEQUENCE public.user_season_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_season_stats_id_seq OWNER TO casebot;

--
-- Name: user_season_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: casebot
--

ALTER SEQUENCE public.user_season_stats_id_seq OWNED BY public.user_season_stats.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: casebot
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(64),
    first_name character varying(64),
    role character varying(16) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    referred_by bigint,
    is_banned boolean DEFAULT false NOT NULL,
    banned_at timestamp with time zone,
    ban_reason character varying(255)
);


ALTER TABLE public.users OWNER TO casebot;

--
-- Name: activity_reward_config id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.activity_reward_config ALTER COLUMN id SET DEFAULT nextval('public.activity_reward_config_id_seq'::regclass);


--
-- Name: case_items id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.case_items ALTER COLUMN id SET DEFAULT nextval('public.case_items_id_seq'::regclass);


--
-- Name: cases id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.cases ALTER COLUMN id SET DEFAULT nextval('public.cases_id_seq'::regclass);


--
-- Name: drops id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.drops ALTER COLUMN id SET DEFAULT nextval('public.drops_id_seq'::regclass);


--
-- Name: manual_rewards id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.manual_rewards ALTER COLUMN id SET DEFAULT nextval('public.manual_rewards_id_seq'::regclass);


--
-- Name: point_transactions id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.point_transactions ALTER COLUMN id SET DEFAULT nextval('public.point_transactions_id_seq'::regclass);


--
-- Name: seasons id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.seasons ALTER COLUMN id SET DEFAULT nextval('public.seasons_id_seq'::regclass);


--
-- Name: tournament_entries id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournament_entries ALTER COLUMN id SET DEFAULT nextval('public.tournament_entries_id_seq'::regclass);


--
-- Name: tournament_templates id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournament_templates ALTER COLUMN id SET DEFAULT nextval('public.tournament_templates_id_seq'::regclass);


--
-- Name: tournaments id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN id SET DEFAULT nextval('public.tournaments_id_seq'::regclass);


--
-- Name: user_season_stats id; Type: DEFAULT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.user_season_stats ALTER COLUMN id SET DEFAULT nextval('public.user_season_stats_id_seq'::regclass);


--
-- Data for Name: activity_reward_config; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.activity_reward_config (id, season_id, points_comment, points_subscription, points_referral, daily_limit_comment, min_comment_length, comment_cooldown_seconds, block_duplicate_comments, referral_requires_action, quality_weight_fn, quality_weight_mw, quality_weight_ft, quality_weight_ww, quality_weight_bs, mult_fn, mult_mw, mult_ft, mult_ww, mult_bs, stattrak_chance, stattrak_multiplier) FROM stdin;
1	1	10	500	250	4	10	45	f	t	10	20	50	15	5	1.45	1.15	0.85	0.65	0.5	50	2.1
\.


--
-- Data for Name: case_items; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.case_items (id, case_id, name, rarity, weight, quality_score, point_value, deleted_at, image_url) FROM stdin;
9	3	АК-47 Пустынный повстанец	Covert	6	50	800	\N	/static/images/item_9_2cc254e8.png
10	3	M4A1-S Золотая спираль	Covert	12	4	650	\N	/static/images/item_10_85758433.png
13	3	AWP Азимов	Covert	5	1	1200	\N	/static/images/item_13_6179ab75.png
14	3	USP-S Поток информации	Covert	17	1	480	\N	/static/images/item_14_e182ed1c.png
15	3	АК-47 Снежный вихрь	Classified	35	1	290	\N	/static/images/item_15_032b9eb7.png
16	3	CZ75-Auto Сян-лю	Classified	45	1	264	\N	/static/images/item_16_ced7b340.png
17	3	AWP Ледяной уголь	Classified	51	1	198	\N	/static/images/item_17_09c55c85.png
18	3	MP7 Градиент	Restricted	89	1	170	\N	/static/images/item_18_87d0ea91.png
1	1	Серый болт	Consumer	65	1	5	\N	\N
5	2	Медный диск	Consumer	50	1	15	\N	\N
12	3	Trash	Consumer	400	1	0	2026-11-11 17:28:18.22062+00	\N
11	3	Che	Consumer	45	1	1	2026-11-11 17:28:32.871975+00	\N
2	1	Синий клинок	Mil-Spec	25	5	40	\N	\N
6	2	Серебряный кубок	Mil-Spec	35	5	80	\N	\N
3	1	Пурпурный шар	Classified	8	20	150	\N	\N
7	2	Платиновое кольцо	Classified	12	20	400	\N	\N
4	1	Золотой череп	Covert	2	100	600	\N	\N
8	2	Корона	Covert	3	100	1500	\N	\N
39	4	Зеленый Глянец	Mil-Spec	5	1	1167	\N	/static/images/item_7e1d34b2.png
27	4	Каратель	Classified	5	1	1190	\N	/static/images/item_f3514c9a.png
51	5	Скоростной Зверь	Covert	2	1	2815	\N	/static/images/item_1c4fa151.png
45	4	Хищник	Industrial	11	1	8764	2026-11-14 17:55:28.09565+00	\N
74	6	Золотая Спираль	Covert	1	1	4593	\N	/static/images/item_1e958017.png
75	6	Вейпорейв	Covert	1	1	3648	\N	/static/images/item_7c83a0da.png
76	6	Атомный Сплав	Classified	2	1	1922	\N	/static/images/item_b7278cbb.png
78	6	Опустошитель	Classified	5	1	941	\N	/static/images/item_71237ac6.png
79	6	Хрусталь	Classified	6	1	843	\N	/static/images/item_7a00e05f.png
80	6	Ночной Кошмар	Classified	8	1	698	\N	/static/images/item_a5ba838d.png
81	6	Черный Лотос	Classified	20	1	286	\N	/static/images/item_c3598dd9.png
48	5	Дикое Пламя	Covert	1	1	3314	\N	/static/images/item_702c3801.png
65	5	Поп-AWP	Restricted	20	1	437	\N	/static/images/item_94073964.png
66	5	Экзоскелет	Restricted	24	1	388	\N	/static/images/item_7778c21b.png
63	5	Древесная Гадюка	Restricted	52	1	335	\N	/static/images/item_82cf0f79.png
69	5	Черный Нил	Mil-Spec	70	1	198	\N	/static/images/item_e798faf2.png
62	5	Фобос	Restricted	75	1	171	\N	/static/images/item_01515c35.png
67	5	Бог Червей	Restricted	75	1	170	\N	/static/images/item_1079bf4f.png
64	5	ЛАПКИ	Restricted	80	1	155	\N	/static/images/item_c2fc5a22.png
68	5	Гадюка	Restricted	90	1	67	\N	/static/images/item_714524a1.png
70	5	Ахерон	Mil-Spec	90	1	66	\N	/static/images/item_11135eb8.png
71	5	Капилляры	Mil-Spec	92	1	55	\N	/static/images/item_3c70e800.png
72	5	Разлив Мышьяка	Mil-Spec	100	1	30	\N	/static/images/item_eb3bb869.png
22	4	Неоновый Гонщик	Covert	1	1	3470	\N	/static/images/item_22_8f83fbf5.png
23	4	Азимов	Covert	1	1	3320	\N	/static/images/item_23_d40d87ce.png
25	4	Аквамариновая Месть	Covert	1	1	2970	\N	/static/images/item_293000fe.png
24	4	Легион Анубиса	Covert	2	1	2430	\N	/static/images/item_c0a251d5.png
26	4	Выстрел в Голову	Covert	2	1	2350	\N	/static/images/item_0d676a2c.png
34	4	Орбита вер.01	Restricted	3	1	1810	\N	/static/images/item_b59585d4.png
36	4	Синий Ламинат	Restricted	6	1	1040	\N	/static/images/item_0df6e921.png
28	4	Буйство Красок	Classified	7	1	960	\N	/static/images/item_9d691942.png
32	4	Нуво Руж	Classified	11	1	620	\N	/static/images/item_fd2839c9.png
30	4	Дилетанты	Classified	15	1	470	\N	/static/images/item_42794d60.png
31	4	Фантомный Вредитель	Classified	16	1	450	\N	/static/images/item_d8452a91.png
33	4	Жгучая Ярость	Classified	20	1	350	\N	/static/images/item_9aaa1629.png
29	4	Ледяной Уголь	Classified	21	1	340	\N	/static/images/item_7a683659.png
35	4	Сланец	Restricted	22	1	324	\N	/static/images/item_9fe87841.png
38	4	Колымага	Restricted	25	1	298	\N	/static/images/item_9bb1c80a.png
37	4	Полуночный Глянец	Restricted	55	1	194	\N	/static/images/item_b5650473.png
44	4	Плавный Переход	Mil-Spec	65	1	146	\N	/static/images/item_3496f57b.png
42	4	Элитное Снаряжение	Mil-Spec	68	1	138	\N	/static/images/item_efa5577d.png
40	4	Стальная Дельта	Mil-Spec	70	1	135	\N	/static/images/item_c574db38.png
43	4	Затерянная Земля	Mil-Spec	88	1	45	\N	/static/images/item_9036827a.png
41	4	Зимняя Зелень	Mil-Spec	94	1	36	\N	/static/images/item_41_edca62d7.png
47	4	Смешанный Серый	Industrial	100	1	24	\N	/static/images/item_22f8f461.png
52	5	Хроматическая Аберрация	Covert	2	1	2416	\N	/static/images/item_79d79319.png
53	5	Электрический Улей	Classified	3	1	2019	\N	/static/images/item_866ecc63.png
145	9	Предатель	Covert	2	1	3974	\N	/static/images/item_7aed6251.png
148	9	Оранжевый Анолис	Classified	3	1	1797	\N	/static/images/item_9360aff9.png
146	9	Чудовищная Смесь	Classified	4	1	1500	\N	/static/images/item_7e5d3b94.png
155	9	Нержавейка	Mil-Spec	6	1	516	\N	/static/images/item_d26fad9c.png
147	9	Извилины	Classified	11	1	280	\N	/static/images/item_19deb625.png
149	9	Сайрекс	Classified	13	1	245	\N	/static/images/item_b4eb4ddc.png
151	9	Страж	Classified	17	1	199	\N	/static/images/item_0b326020.png
162	9	Горный Камуфляж	Mil-Spec	45	1	98	\N	/static/images/item_33e575f2.png
161	9	Неисправность	Mil-Spec	48	1	97	\N	/static/images/item_e53b6649.png
152	9	Кровопролитная Элита	Classified	65	1	78	\N	/static/images/item_43f308dd.png
154	9	Билет в Ад	Classified	78	1	63	\N	/static/images/item_4c98bbba.png
150	9	Взгляд в Прошлое	Classified	90	1	53	\N	/static/images/item_55d7c509.png
153	9	Королевский Страж	Classified	95	1	38	\N	/static/images/item_1a7365f5.png
140	8	Ночь	Industrial	4	1	1043	\N	/static/images/item_8b696d46.png
141	8	Ночная Буря	Industrial	6	1	882	\N	/static/images/item_ea10fc4f.png
129	8	Наследие	Restricted	11	1	499	\N	/static/images/item_9afd2d07.png
142	8	Бронзовый	Industrial	22	1	153	\N	/static/images/item_5343f68d.png
135	8	Спутник	Mil-Spec	50	1	104	\N	/static/images/item_08053680.png
144	8	Пиксельный Камуфляж	Industrial	52	1	103	\N	/static/images/item_f15ea952.png
143	8	Недовольство	Industrial	56	1	98	\N	/static/images/item_dc64e5a4.png
131	8	Рельсотрон	Restricted	65	1	85	\N	/static/images/item_5981246e.png
136	8	Метеорит	Mil-Spec	65	1	85	\N	/static/images/item_2d2da1a8.png
137	8	Оксидное Пламя	Mil-Spec	70	1	81	\N	/static/images/item_dc399761.png
132	8	Стрелковая Дисциплина	Restricted	78	1	59	\N	/static/images/item_6c63ecda.png
139	8	Бронзовая Декорация	Mil-Spec	85	1	49	\N	/static/images/item_0805cb81.png
134	8	Синяя Фанера	Mil-Spec	92	1	45	\N	/static/images/item_86759f60.png
138	8	Каллиграффити	Mil-Spec	92	1	45	\N	/static/images/item_09927acd.png
133	8	Змеиный Выпад	Restricted	100	1	35	\N	/static/images/item_d9d98fa6.png
77	6	Панель Управления	Classified	3	1	1481	\N	/static/images/item_1eaf0aa8.png
82	6	Уединение	Classified	55	1	126	\N	/static/images/item_10528490.png
49	5	Распространение	Covert	1	1	4223	\N	/static/images/item_e7a66c68.png
50	5	Поток информации	Covert	1	1	3390	\N	/static/images/item_b5892704.png
55	5	Бдыщ!	Classified	4	1	1670	\N	/static/images/item_163f3c2e.png
54	5	Кортисейра	Classified	4	1	1584	\N	/static/images/item_9dbabf06.png
57	5	Горячечные Грёзы	Classified	7	1	967	\N	/static/images/item_5f4c0e75.png
58	5	Элитное Снаряжение	Classified	9	1	835	\N	/static/images/item_46fdd66d.png
59	5	Двойственность	Classified	10	1	793	\N	/static/images/item_6ba558a7.png
56	5	Ледяной Уголь	Classified	15	1	537	\N	/static/images/item_887018c4.png
61	5	Зеленая Энергия	Classified	17	1	488	\N	/static/images/item_6cc8c7b4.png
60	5	Мортис	Classified	60	1	269	\N	/static/images/item_2c76757c.png
120	7	Тигр в Джунглях	Industrial	15	1	327	\N	/static/images/item_e71fd780.png
110	7	Листовая Молния	Restricted	75	1	52	\N	/static/images/item_d31fa250.png
84	6	Василиск	Restricted	10	1	576	\N	/static/images/item_7a93eee8.png
92	6	Кровавый Тигр	Mil-Spec	14	1	396	\N	/static/images/item_3ded17d9.png
90	6	Ночной Ужас	Restricted	88	1	47	\N	/static/images/item_80e06de6.png
73	5	Солнце в Знаке Льва	Mil-Spec	5	1	1319	\N	/static/images/item_ef67e151.png
108	7	Злобный Даймё	Restricted	20	1	223	\N	/static/images/item_28b8bb47.png
115	7	Преобразователь	Restricted	48	1	160	\N	/static/images/item_4431c8a9.png
116	7	Рубитель	Restricted	65	1	79	\N	/static/images/item_bfb59dd0.png
114	7	Полимерный Рожок	Restricted	100	1	22	\N	/static/images/item_4497d1ec.png
93	6	Брифинг	Mil-Spec	16	1	341	\N	/static/images/item_31ace2a7.png
86	6	Взгляд в Прошлое	Restricted	18	1	320	\N	/static/images/item_78f26485.png
85	6	Ликвидация	Restricted	45	1	169	\N	/static/images/item_a8755fa6.png
87	6	Электрум	Restricted	72	1	88	\N	/static/images/item_645f45af.png
89	6	Эмфорозавр-S	Restricted	95	1	39	\N	/static/images/item_0553f10b.png
46	4	Оливковый Поликамуфляж	Industrial	97	1	30	\N	/static/images/item_279a982a.png
98	7	Темукау	Covert	2	1	2323	\N	/static/images/item_eb110a3e.png
99	7	Звездный Крейсер	Covert	2	1	2098	\N	/static/images/item_8838e90d.png
100	7	Кибербезопасность	Classified	3	1	1488	\N	/static/images/item_03587de8.png
101	7	Безлюдный Космос	Classified	5	1	990	\N	/static/images/item_f91d8f88.png
102	7	Король Драконов	Classified	5	1	973	\N	/static/images/item_c5ad2555.png
106	7	Ликорис Лучистый	Restricted	9	1	616	\N	/static/images/item_d328462d.png
119	7	Смерч	Industrial	11	1	532	\N	/static/images/item_d33b56e7.png
104	7	Зубная Фея	Classified	17	1	289	\N	/static/images/item_9fca978b.png
112	7	Тусклые Полосы	Mil-Spec	17	1	284	\N	/static/images/item_184d8b8d.png
94	6	Поп-шипучка	Mil-Spec	62	1	106	\N	/static/images/item_6446cc8f.png
88	6	Глюк-краска	Restricted	70	1	90	\N	/static/images/item_18784bd6.png
95	6	Грязевой Стандарт	Industrial	85	1	50	\N	/static/images/item_7d8c4d85.png
96	7	В Живом Цвете	Covert	1	1	2413	\N	/static/images/item_bde983fb.png
97	7	Нео-нуар	Covert	1	1	2419	\N	/static/images/item_58ae9a0e.png
103	7	Адок	Classified	1	1	3005	\N	/static/images/item_dafdae16.png
91	6	Нитро	Restricted	100	1	33	\N	/static/images/item_b69581e4.png
168	9	Пустынная Тактика	Industrial	100	1	23	\N	/static/images/item_c6de50bf.png
156	9	Калька	Mil-Spec	3	1	342	\N	/static/images/item_918ecdc6.png
157	9	Кровавый Тигр	Mil-Spec	15	1	217	\N	/static/images/item_e24e0c67.png
164	9	Проводник	Mil-Spec	60	1	81	\N	/static/images/item_11547912.png
166	9	Королевский Синий	Industrial	1	1	5689	\N	/static/images/item_3afaf437.png
165	9	ПК-ЗЛН	Mil-Spec	65	1	78	\N	/static/images/item_b217ed11.png
158	9	Черный Лотос	Mil-Spec	70	1	77	\N	/static/images/item_48be428b.png
167	9	Едва Зелёный	Industrial	7	1	494	\N	/static/images/item_876973c1.png
159	9	Закрученный	Mil-Spec	20	1	137	\N	/static/images/item_18c9bb98.png
163	9	Тропический Бриз	Mil-Spec	52	1	93	\N	/static/images/item_4fb7b8db.png
160	9	Бесшумный Выстрел	Mil-Spec	85	1	57	\N	/static/images/item_e96c25b6.png
19	3	MP9 Latte Rush	Restricted	95	1	165	\N	/static/images/item_19_ceec3373.png
20	3	Glock-18 Зеркальная мозаика	Restricted	99	1	130	\N	/static/images/item_e542948c.png
21	3	AWP Гадюка	Restricted	115	1	120	\N	/static/images/item_233a4038.png
124	8	Дракон-предводитель	Classified	2	1	1393	\N	/static/images/item_ceff88e3.png
127	8	Кровавая Паутина	Restricted	8	1	804	\N	/static/images/item_e3e0bb53.png
125	8	Механо-пушка	Classified	14	1	416	\N	/static/images/item_e20865de.png
130	8	Нага	Restricted	25	1	150	\N	/static/images/item_a7bf18e2.png
128	8	Директива	Restricted	58	1	96	\N	/static/images/item_88246172.png
126	8	Термическая Обработка	Classified	65	1	85	\N	/static/images/item_fdff3208.png
113	7	Global Offensive	Restricted	4	1	1279	\N	/static/images/item_b344c1a1.png
117	7	Песчаная Буря	Restricted	6	1	822	\N	/static/images/item_6d4f2377.png
118	7	Темное Цветение	Industrial	8	1	697	\N	/static/images/item_aeb20be4.png
105	7	Полигональная Смесь	Restricted	8	1	646	\N	/static/images/item_a469dbdf.png
107	7	Грифон	Restricted	20	1	226	\N	/static/images/item_90d399c8.png
109	7	Турбина	Restricted	58	1	104	\N	/static/images/item_f3ac7b49.png
111	7	Мастер Травли	Restricted	88	1	26	\N	/static/images/item_20de93db.png
122	7	Стальной Каркас	Industrial	95	1	23	\N	/static/images/item_ebe87751.png
121	7	Мейнфрейм	Industrial	100	1	22	\N	/static/images/item_0d0ad2b2.png
83	6	Стратосфера	Classified	20	1	286	\N	/static/images/item_38685ae8.png
123	8	Поток Информации	Covert	1	1	2596	\N	/static/images/item_9eba76d7.png
\.


--
-- Data for Name: cases; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.cases (id, season_id, name, price_points, is_active, created_by, image_url) FROM stdin;
1	1	Checkrename	120	f	\N	\N
2	1	Золотой	300	f	\N	\N
4	1	АК-47	279	t	1448305237	\N
5	1	AWP	350	t	1448305237	\N
6	1	M4A1-C	179	t	1448305237	\N
7	1	M4A4	199	t	1448305237	\N
8	1	DESERRT EAGLE	149	t	1448305237	\N
9	1	USP-S	129	t	1448305237	\N
3	1	Donk case	50	f	965425988	/static/images/case_3_f04dc3fe.webp
\.


--
-- Data for Name: drops; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.drops (id, season_id, user_id, case_id, item_id, rolled_at, float_value, quality, is_stattrak, final_price, is_sold) FROM stdin;
194	1	965425988	3	16	2026-11-13 22:59:58.996762+00	0.4717	BS	f	132	t
211	1	965425988	3	17	2026-11-14 11:31:26.84499+00	0.5805	BS	t	207	t
193	1	965425988	3	20	2026-11-13 22:59:48.016251+00	0.0857	MW	f	149	t
192	1	965425988	3	10	2026-11-13 22:59:37.615449+00	0.4573	BS	t	682	t
240	1	1448305237	3	20	2026-11-14 13:31:23.870679+00	0.4552	BS	t	136	t
237	1	1448305237	3	18	2026-11-14 13:31:04.174615+00	0.3789	FT	t	303	t
229	1	1448305237	3	13	2026-11-14 13:30:10.078974+00	0.9667	BS	t	1260	t
330	1	1629242254	3	17	2026-11-14 13:46:55.163168+00	0.1539	FT	t	353	t
312	1	1629242254	3	19	2026-11-14 13:46:03.491454+00	0.619	BS	f	82	t
209	1	1629242254	3	19	2026-11-14 11:29:39.84235+00	0.4899	BS	t	173	t
350	1	1448305237	3	21	2026-11-14 13:48:10.756879+00	0.1008	MW	t	289	t
341	1	1448305237	3	18	2026-11-14 13:47:38.546464+00	0.6283	BS	t	178	t
339	1	1448305237	3	19	2026-11-14 13:47:32.926966+00	0.7541	BS	t	173	t
337	1	1448305237	3	20	2026-11-14 13:47:27.259956+00	0.1091	MW	t	313	t
334	1	1448305237	3	18	2026-11-14 13:47:15.808833+00	0.8051	BS	f	85	t
333	1	1448305237	3	20	2026-11-14 13:47:10.204012+00	0.8194	BS	t	136	t
332	1	1448305237	3	14	2026-11-14 13:47:01.764833+00	0.7368	BS	t	504	t
307	1	1448305237	3	21	2026-11-14 13:45:40.813272+00	0.7482	BS	t	126	t
305	1	1448305237	3	21	2026-11-14 13:45:29.289447+00	0.4085	WW	f	78	t
303	1	1448305237	3	20	2026-11-14 13:45:17.282987+00	0.4048	WW	t	177	t
301	1	1448305237	3	21	2026-11-14 13:45:02.609671+00	0.3163	FT	f	102	t
299	1	1448305237	3	19	2026-11-14 13:44:50.918601+00	0.9705	BS	f	82	t
290	1	1448305237	3	13	2026-11-14 13:43:49.133624+00	0.2039	FT	t	2142	t
288	1	1448305237	3	18	2026-11-14 13:43:38.020202+00	0.7636	BS	f	85	t
286	1	1448305237	3	18	2026-11-14 13:43:26.733798+00	0.8814	BS	f	85	t
284	1	1448305237	3	15	2026-11-14 13:43:15.291982+00	0.5192	BS	f	145	t
282	1	1448305237	3	21	2026-11-14 13:43:03.89283+00	0.4729	BS	t	126	t
280	1	1448305237	3	18	2026-11-14 13:42:51.693666+00	0.9235	BS	t	178	t
397	1	1448305237	3	16	2026-11-14 13:52:13.882247+00	0.9038	BS	t	277	t
395	1	1448305237	3	10	2026-11-14 13:52:02.84958+00	0.3373	FT	f	552	t
393	1	1448305237	3	21	2026-11-14 13:51:52.006186+00	0.1051	MW	f	138	t
391	1	1448305237	3	18	2026-11-14 13:51:41.143778+00	0.5247	BS	f	85	t
389	1	1448305237	3	21	2026-11-14 13:51:29.975303+00	0.3635	FT	t	214	t
368	1	1448305237	3	21	2026-11-14 13:50:30.161512+00	0.2574	FT	t	214	t
367	1	1448305237	3	20	2026-11-14 13:50:24.727774+00	0.4693	BS	f	65	t
365	1	1448305237	3	21	2026-11-14 13:50:13.313599+00	0.9162	BS	f	60	t
363	1	1448305237	3	20	2026-11-14 13:50:02.060103+00	0.0237	FN	f	188	t
474	1	1913085298	3	17	2026-11-14 14:29:13.638786+00	0.9369	BS	t	207	t
476	1	1913085298	3	21	2026-11-14 14:29:28.92885+00	0.5603	BS	t	126	t
478	1	1913085298	3	10	2026-11-14 14:29:40.909484+00	0.5648	BS	f	325	t
495	1	1913085298	3	21	2026-11-14 14:37:13.837315+00	0.266	FT	f	102	t
493	1	1913085298	3	19	2026-11-14 14:37:02.260848+00	0.7449	BS	f	82	t
491	1	1913085298	3	20	2026-11-14 14:36:50.637625+00	0.4786	BS	t	136	t
483	1	1913085298	3	18	2026-11-14 14:32:42.121428+00	0.327	FT	f	144	t
481	1	1913085298	3	19	2026-11-14 14:32:30.337896+00	0.893	BS	t	173	t
519	1	1913085298	3	21	2026-11-14 14:43:48.060472+00	0.4397	WW	f	78	t
515	1	1913085298	3	20	2026-11-14 14:43:25.670609+00	0.5318	BS	f	65	t
387	1	1629242254	3	19	2026-11-14 13:51:21.296856+00	0.4677	BS	t	173	t
385	1	1629242254	3	18	2026-11-14 13:51:15.851288+00	0.3409	FT	t	303	t
383	1	1629242254	3	16	2026-11-14 13:51:10.17498+00	0.2507	FT	t	471	t
379	1	1629242254	3	17	2026-11-14 13:50:58.737279+00	0.6985	BS	t	207	t
377	1	1629242254	3	15	2026-11-14 13:50:53.096701+00	0.3958	WW	t	395	t
359	1	1629242254	3	21	2026-11-14 13:48:56.321954+00	0.5038	BS	f	60	t
352	1	1629242254	3	17	2026-11-14 13:48:16.925271+00	0.7213	BS	f	99	t
343	1	1629242254	3	21	2026-11-14 13:47:46.909013+00	0.3871	WW	t	163	t
196	1	1170057607	3	10	2026-11-13 23:10:17.960393+00	0.0131	FN	t	1979	t
121	1	7756709710	3	17	2026-11-12 18:32:29.982447+00	\N	\N	f	\N	t
124	1	1629242254	3	15	2026-11-12 18:52:21.972417+00	\N	\N	f	\N	t
131	1	1629242254	3	17	2026-11-12 18:53:02.063358+00	\N	\N	f	\N	t
136	1	233835983	3	10	2026-11-12 18:57:54.423083+00	\N	\N	f	\N	t
141	1	1448305237	3	19	2026-11-12 18:59:53.030336+00	\N	\N	f	\N	t
147	1	1629242254	3	19	2026-11-12 19:47:12.175709+00	\N	\N	f	\N	t
149	1	1629242254	3	18	2026-11-12 20:34:21.756247+00	\N	\N	f	\N	t
158	1	1629242254	3	15	2026-11-12 23:09:59.593513+00	\N	\N	f	\N	t
163	1	1629242254	3	10	2026-11-12 23:10:30.805796+00	\N	\N	f	\N	t
169	1	1913085298	3	18	2026-11-13 14:30:06.385896+00	\N	\N	f	\N	t
195	1	965425988	3	16	2026-11-13 23:01:19.690586+00	0.7966	BS	t	277	t
213	1	965425988	3	15	2026-11-14 12:33:56.653381+00	0.2049	FT	f	246	t
212	1	965425988	3	19	2026-11-14 12:29:40.670243+00	0.4142	WW	f	107	t
201	1	965425988	3	21	2026-11-13 23:23:29.44925+00	0.5497	BS	t	126	t
252	1	1448305237	3	16	2026-11-14 13:34:29.148869+00	0.495	BS	f	132	t
251	1	1448305237	3	21	2026-11-14 13:34:23.503405+00	0.1681	FT	f	102	t
249	1	1448305237	3	10	2026-11-14 13:34:10.769332+00	0.1793	FT	f	552	t
247	1	1448305237	3	20	2026-11-14 13:33:59.127982+00	0.8827	BS	f	65	t
276	1	1448305237	3	20	2026-11-14 13:40:07.180396+00	0.7709	BS	t	136	t
274	1	1448305237	3	19	2026-11-14 13:39:56.212737+00	0.1807	FT	f	140	t
265	1	1448305237	3	14	2026-11-14 13:38:47.99848+00	0.8032	BS	t	504	t
263	1	1448305237	3	19	2026-11-14 13:38:35.320894+00	0.1038	MW	t	398	t
260	1	1448305237	3	19	2026-11-14 13:38:15.020743+00	0.6819	BS	f	82	t
258	1	1448305237	3	17	2026-11-14 13:38:00.127983+00	0.3327	FT	f	168	t
348	1	1448305237	3	10	2026-11-14 13:48:00.972624+00	0.3194	FT	t	1160	t
346	1	1448305237	3	21	2026-11-14 13:47:54.382466+00	0.0217	FN	t	365	t
331	1	1448305237	3	18	2026-11-14 13:46:56.263259+00	0.3018	FT	t	303	t
329	1	1448305237	3	21	2026-11-14 13:46:50.862909+00	0.0102	FN	t	365	t
308	1	1448305237	3	19	2026-11-14 13:45:46.347874+00	0.9715	BS	f	82	t
306	1	1448305237	3	19	2026-11-14 13:45:35.089095+00	0.9088	BS	t	173	t
304	1	1448305237	3	16	2026-11-14 13:45:23.714401+00	0.3904	WW	f	171	t
302	1	1448305237	3	14	2026-11-14 13:45:11.285305+00	0.5409	BS	t	504	t
300	1	1448305237	3	18	2026-11-14 13:44:56.641372+00	0.3039	FT	t	303	t
289	1	1448305237	3	19	2026-11-14 13:43:43.718845+00	0.7726	BS	t	173	t
287	1	1448305237	3	21	2026-11-14 13:43:32.373212+00	0.9055	BS	f	60	t
285	1	1448305237	3	19	2026-11-14 13:43:20.951695+00	0.1706	FT	t	294	t
283	1	1448305237	3	18	2026-11-14 13:43:09.615614+00	0.3738	FT	t	303	t
281	1	1448305237	3	21	2026-11-14 13:42:57.510508+00	0.294	FT	f	102	t
392	1	1448305237	3	18	2026-11-14 13:51:46.659622+00	0.4423	WW	f	110	t
374	1	1448305237	3	16	2026-11-14 13:50:46.781721+00	0.6173	BS	f	132	t
372	1	1448305237	3	16	2026-11-14 13:50:41.093123+00	0.9705	BS	f	132	t
370	1	1448305237	3	19	2026-11-14 13:50:35.644122+00	0.9063	BS	f	82	t
565	1	1913085298	3	21	2026-11-14 14:48:06.99569+00	0.62	BS	f	60	t
546	1	1913085298	3	21	2026-11-14 14:46:19.718177+00	0.7465	BS	t	126	t
542	1	1913085298	3	20	2026-11-14 14:45:57.362826+00	0.7906	BS	f	65	t
527	1	1913085298	3	21	2026-11-14 14:44:32.713061+00	0.9941	BS	f	60	t
357	1	1629242254	3	10	2026-11-14 13:48:45.361038+00	0.479	BS	f	325	t
355	1	1629242254	3	21	2026-11-14 13:48:34.103166+00	0.0301	FN	f	174	t
353	1	1629242254	3	19	2026-11-14 13:48:23.062422+00	0.1676	FT	f	140	t
197	1	1170057607	3	21	2026-11-13 23:10:25.648132+00	0.5477	BS	f	60	t
200	1	1170057607	3	16	2026-11-13 23:10:44.864907+00	0.6707	BS	t	277	t
403	1	1448305237	3	16	2026-11-14 13:54:55.951149+00	0.6147	BS	f	132	t
405	1	1448305237	3	16	2026-11-14 13:55:06.975241+00	0.6151	BS	f	132	t
122	1	7756709710	3	19	2026-11-12 18:32:35.551669+00	\N	\N	f	\N	t
123	1	1629242254	3	18	2026-11-12 18:52:15.231617+00	\N	\N	f	\N	t
130	1	1629242254	3	18	2026-11-12 18:52:55.194231+00	\N	\N	f	\N	t
135	1	233835983	3	18	2026-11-12 18:57:48.571735+00	\N	\N	f	\N	t
140	1	1448305237	3	10	2026-11-12 18:59:46.917703+00	\N	\N	f	\N	t
146	1	1629242254	3	21	2026-11-12 19:47:06.969441+00	\N	\N	f	\N	t
151	1	1629242254	3	21	2026-11-12 20:34:32.51834+00	\N	\N	f	\N	t
153	1	1629242254	3	20	2026-11-12 20:34:43.557151+00	\N	\N	f	\N	t
157	1	1629242254	3	18	2026-11-12 23:09:53.866482+00	\N	\N	f	\N	t
162	1	1629242254	3	18	2026-11-12 23:10:25.463505+00	\N	\N	f	\N	t
214	1	965425988	3	14	2026-11-14 12:46:34.536122+00	0.9689	BS	f	240	t
254	1	1448305237	3	15	2026-11-14 13:34:40.48443+00	0.4031	WW	t	395	t
250	1	1448305237	3	20	2026-11-14 13:34:17.560848+00	0.099	MW	t	313	t
248	1	1448305237	3	21	2026-11-14 13:34:04.991032+00	0.426	WW	t	163	t
271	1	1448305237	3	21	2026-11-14 13:39:39.2543+00	0.7983	BS	t	126	t
269	1	1448305237	3	20	2026-11-14 13:39:26.79386+00	0.064	FN	f	188	t
267	1	1448305237	3	15	2026-11-14 13:39:06.36415+00	0.8368	BS	f	145	t
255	1	1448305237	3	21	2026-11-14 13:37:37.261158+00	0.7017	BS	f	60	t
328	1	1629242254	3	20	2026-11-14 13:46:49.712452+00	0.2058	FT	f	110	t
326	1	1629242254	3	18	2026-11-14 13:46:44.199491+00	0.2247	FT	f	144	t
324	1	1629242254	3	20	2026-11-14 13:46:38.570733+00	0.6824	BS	t	136	t
322	1	1629242254	3	19	2026-11-14 13:46:33.067025+00	0.8139	BS	t	173	t
320	1	1629242254	3	21	2026-11-14 13:46:27.44187+00	0.5369	BS	t	126	t
318	1	1629242254	3	17	2026-11-14 13:46:21.315543+00	0.1789	FT	f	168	t
316	1	1629242254	3	18	2026-11-14 13:46:15.765809+00	0.8265	BS	f	85	t
314	1	1629242254	3	21	2026-11-14 13:46:09.015145+00	0.1035	MW	t	289	t
344	1	1448305237	3	18	2026-11-14 13:47:48.521064+00	0.1806	FT	f	144	t
335	1	1448305237	3	18	2026-11-14 13:47:21.38582+00	0.8507	BS	t	178	t
380	1	1448305237	3	21	2026-11-14 13:51:03.180483+00	0.5962	BS	f	60	t
378	1	1448305237	3	20	2026-11-14 13:50:57.739419+00	0.4172	WW	t	177	t
376	1	1448305237	3	20	2026-11-14 13:50:52.259103+00	0.5894	BS	f	65	t
366	1	1448305237	3	17	2026-11-14 13:50:18.869399+00	0.2439	FT	t	353	t
364	1	1448305237	3	21	2026-11-14 13:50:07.706981+00	0.8854	BS	f	60	t
508	1	1913085298	3	20	2026-11-14 14:38:37.246516+00	0.0934	MW	f	149	t
506	1	1913085298	3	21	2026-11-14 14:38:25.34082+00	0.9408	BS	t	126	t
504	1	1913085298	3	21	2026-11-14 14:38:13.710775+00	0.4031	WW	t	163	t
502	1	1913085298	3	18	2026-11-14 14:37:56.201859+00	0.4995	BS	t	178	t
487	1	1913085298	3	18	2026-11-14 14:33:10.897695+00	0.7924	BS	t	178	t
485	1	1913085298	3	20	2026-11-14 14:32:53.45386+00	0.6843	BS	t	136	t
564	1	1913085298	3	19	2026-11-14 14:48:01.285008+00	0.7932	BS	t	173	t
549	1	1913085298	3	19	2026-11-14 14:46:36.518222+00	0.1827	FT	f	140	t
545	1	1913085298	3	20	2026-11-14 14:46:14.168318+00	0.9119	BS	t	136	t
543	1	1913085298	3	21	2026-11-14 14:46:03.386074+00	0.3815	WW	f	78	t
541	1	1913085298	3	17	2026-11-14 14:45:51.890895+00	0.4785	BS	f	99	t
530	1	1913085298	3	19	2026-11-14 14:44:49.905908+00	0.7901	BS	f	82	t
528	1	1913085298	3	21	2026-11-14 14:44:38.70564+00	0.8246	BS	t	126	t
526	1	1913085298	3	20	2026-11-14 14:44:27.118129+00	0.4995	BS	f	65	t
524	1	1913085298	3	18	2026-11-14 14:44:16.125063+00	0.7004	BS	t	178	t
521	1	1913085298	3	18	2026-11-14 14:43:58.874619+00	0.764	BS	t	178	t
513	1	1913085298	3	19	2026-11-14 14:42:30.066505+00	0.8751	BS	t	173	t
511	1	1913085298	3	18	2026-11-14 14:42:18.544473+00	0.4756	BS	t	178	t
361	1	1629242254	3	9	2026-11-14 13:49:07.262831+00	0.6862	BS	f	400	t
360	1	1629242254	3	20	2026-11-14 13:49:01.817536+00	0.7223	BS	f	65	t
358	1	1629242254	3	18	2026-11-14 13:48:50.899133+00	0.6483	BS	t	178	t
342	1	1629242254	3	20	2026-11-14 13:47:41.388376+00	0.7901	BS	t	136	t
340	1	1629242254	3	21	2026-11-14 13:47:35.840661+00	0.3757	FT	t	214	t
338	1	1629242254	3	16	2026-11-14 13:47:30.404037+00	0.3872	WW	t	360	t
336	1	1629242254	3	19	2026-11-14 13:47:24.721668+00	0.0817	MW	t	398	t
198	1	1170057607	3	18	2026-11-13 23:10:31.516602+00	0.7927	BS	t	178	t
125	1	1629242254	3	21	2026-11-12 18:52:27.822326+00	\N	\N	f	\N	t
127	1	1629242254	3	20	2026-11-12 18:52:38.606125+00	\N	\N	f	\N	t
132	1	1629242254	3	20	2026-11-12 18:53:09.053289+00	\N	\N	f	\N	t
137	1	233835983	3	21	2026-11-12 18:58:00.388086+00	\N	\N	f	\N	t
142	1	1448305237	3	20	2026-11-12 18:59:59.273697+00	\N	\N	f	\N	t
145	1	1629242254	3	21	2026-11-12 19:47:01.641715+00	\N	\N	f	\N	t
150	1	1629242254	3	21	2026-11-12 20:34:27.122733+00	\N	\N	f	\N	t
152	1	1629242254	3	18	2026-11-12 20:34:38.312208+00	\N	\N	f	\N	t
154	1	1629242254	3	18	2026-11-12 23:09:36.831865+00	\N	\N	f	\N	t
159	1	1629242254	3	20	2026-11-12 23:10:05.389389+00	\N	\N	f	\N	t
166	1	1913085298	3	15	2026-11-13 14:29:45.646407+00	\N	\N	f	\N	t
171	1	1913085298	3	16	2026-11-13 14:30:17.978563+00	\N	\N	f	\N	t
206	1	965425988	3	21	2026-11-14 11:11:44.08843+00	0.3043	FT	t	214	t
204	1	965425988	3	18	2026-11-14 11:10:43.392136+00	0.518	BS	t	178	t
203	1	965425988	3	18	2026-11-14 11:10:38.244411+00	0.312	FT	t	303	t
202	1	965425988	3	21	2026-11-14 11:10:32.655293+00	0.2046	FT	t	214	t
253	1	1448305237	3	17	2026-11-14 13:34:34.884587+00	0.5659	BS	f	99	t
272	1	1448305237	3	16	2026-11-14 13:39:45.011226+00	0.5465	BS	f	132	t
270	1	1448305237	3	17	2026-11-14 13:39:32.634221+00	0.5003	BS	f	99	t
268	1	1448305237	3	20	2026-11-14 13:39:20.913014+00	0.6135	BS	f	65	t
266	1	1448305237	3	20	2026-11-14 13:38:54.928463+00	0.07	MW	f	149	t
256	1	1448305237	3	19	2026-11-14 13:37:48.883706+00	0.1924	FT	t	294	t
327	1	1448305237	3	20	2026-11-14 13:46:45.427712+00	0.4413	WW	t	177	t
325	1	1448305237	3	21	2026-11-14 13:46:39.972932+00	0.4559	BS	t	126	t
323	1	1448305237	3	19	2026-11-14 13:46:34.475037+00	0.4469	WW	t	225	t
321	1	1448305237	3	19	2026-11-14 13:46:28.80012+00	0.9859	BS	t	173	t
319	1	1448305237	3	21	2026-11-14 13:46:23.369706+00	0.1571	FT	t	214	t
317	1	1448305237	3	21	2026-11-14 13:46:17.786933+00	0.0807	MW	t	289	t
398	1	1448305237	3	21	2026-11-14 13:52:19.466568+00	0.0327	FN	t	365	t
396	1	1448305237	3	19	2026-11-14 13:52:08.366274+00	0.6816	BS	t	173	t
394	1	1448305237	3	19	2026-11-14 13:51:57.400416+00	0.0572	FN	f	239	t
479	1	1913085298	3	20	2026-11-14 14:29:51.076826+00	0.0197	FN	f	188	t
509	1	1913085298	3	19	2026-11-14 14:38:43.062007+00	0.578	BS	t	173	t
505	1	1913085298	3	17	2026-11-14 14:38:19.654153+00	0.4144	WW	f	128	t
503	1	1913085298	3	18	2026-11-14 14:38:07.766326+00	0.9171	BS	f	85	t
490	1	1913085298	3	17	2026-11-14 14:36:43.708326+00	0.4018	WW	f	128	t
486	1	1913085298	3	19	2026-11-14 14:32:59.170641+00	0.8343	BS	f	82	t
562	1	1913085298	3	21	2026-11-14 14:47:49.967376+00	0.6429	BS	t	126	t
558	1	1913085298	3	18	2026-11-14 14:47:27.664993+00	0.1461	MW	f	195	t
556	1	1913085298	3	19	2026-11-14 14:47:16.115672+00	0.1336	MW	f	189	t
554	1	1913085298	3	21	2026-11-14 14:47:04.132278+00	0.0689	FN	f	174	t
552	1	1913085298	3	21	2026-11-14 14:46:52.953501+00	0.4827	BS	f	60	t
539	1	1913085298	3	21	2026-11-14 14:45:40.970039+00	0.7945	BS	f	60	t
537	1	1913085298	3	18	2026-11-14 14:45:29.877234+00	0.738	BS	f	85	t
535	1	1913085298	3	18	2026-11-14 14:45:18.385867+00	0.7453	BS	t	178	t
533	1	1913085298	3	20	2026-11-14 14:45:06.893685+00	0.841	BS	f	65	t
520	1	1913085298	3	19	2026-11-14 14:43:53.420695+00	0.9045	BS	f	82	t
381	1	1629242254	3	16	2026-11-14 13:51:04.453327+00	0.2506	FT	f	224	t
347	1	1629242254	3	14	2026-11-14 13:47:58.38037+00	0.3135	FT	t	856	t
345	1	1629242254	3	15	2026-11-14 13:47:52.584118+00	0.1164	MW	f	333	t
215	1	965425988	3	16	2026-11-14 13:07:37.473467+00	0.3045	FT	f	224	t
126	1	1629242254	3	18	2026-11-12 18:52:33.152615+00	\N	\N	f	\N	t
128	1	1629242254	3	21	2026-11-12 18:52:44.108448+00	\N	\N	f	\N	t
133	1	1629242254	3	21	2026-11-12 18:53:14.655461+00	\N	\N	f	\N	t
138	1	233835983	3	16	2026-11-12 18:58:07.469921+00	\N	\N	f	\N	t
143	1	1448305237	3	17	2026-11-12 19:00:05.580459+00	\N	\N	f	\N	t
144	1	1629242254	3	20	2026-11-12 19:46:56.137604+00	\N	\N	f	\N	t
155	1	1629242254	3	21	2026-11-12 23:09:42.322573+00	\N	\N	f	\N	t
160	1	1629242254	3	18	2026-11-12 23:10:13.939605+00	\N	\N	f	\N	t
164	1	1913085298	3	15	2026-11-13 10:51:01.324254+00	\N	\N	f	\N	t
168	1	1913085298	3	20	2026-11-13 14:30:00.550264+00	\N	\N	f	\N	t
205	1	965425988	3	16	2026-11-14 11:11:31.280399+00	0.2828	FT	f	224	t
219	1	965425988	3	21	2026-11-14 13:20:05.878735+00	0.933	BS	t	126	t
244	1	1448305237	3	21	2026-11-14 13:31:47.02084+00	0.3169	FT	f	102	t
236	1	1448305237	3	18	2026-11-14 13:30:57.91364+00	0.9164	BS	t	178	t
234	1	1448305237	3	19	2026-11-14 13:30:44.758575+00	0.7171	BS	f	82	t
232	1	1448305237	3	19	2026-11-14 13:30:29.075023+00	0.0345	FN	t	502	t
228	1	1448305237	3	21	2026-11-14 13:30:04.104446+00	0.9922	BS	f	60	t
275	1	1448305237	3	16	2026-11-14 13:40:01.707415+00	0.4605	BS	t	277	t
273	1	1448305237	3	21	2026-11-14 13:39:50.630999+00	0.816	BS	f	60	t
264	1	1448305237	3	19	2026-11-14 13:38:40.877721+00	0.3003	FT	f	140	t
262	1	1448305237	3	18	2026-11-14 13:38:29.592757+00	0.9073	BS	f	85	t
261	1	1448305237	3	16	2026-11-14 13:38:21.15427+00	0.5764	BS	t	277	t
259	1	1448305237	3	16	2026-11-14 13:38:08.555495+00	0.7081	BS	f	132	t
257	1	1448305237	3	19	2026-11-14 13:37:54.53198+00	0.0808	MW	t	398	t
222	1	1629242254	3	18	2026-11-14 13:26:18.207162+00	0.6608	BS	f	85	t
390	1	1448305237	3	18	2026-11-14 13:51:35.629903+00	0.3364	FT	t	303	t
388	1	1448305237	3	21	2026-11-14 13:51:24.641982+00	0.6384	BS	f	60	t
386	1	1448305237	3	20	2026-11-14 13:51:19.30803+00	0.186	FT	f	110	t
384	1	1448305237	3	19	2026-11-14 13:51:13.920181+00	0.7652	BS	t	173	t
382	1	1448305237	3	19	2026-11-14 13:51:08.629106+00	0.6165	BS	t	173	t
475	1	1913085298	3	17	2026-11-14 14:29:21.341758+00	0.0858	MW	t	478	t
477	1	1913085298	3	21	2026-11-14 14:29:34.93009+00	0.4391	WW	t	163	t
500	1	1913085298	3	21	2026-11-14 14:37:44.006944+00	0.5261	BS	f	60	t
498	1	1913085298	3	19	2026-11-14 14:37:31.99098+00	0.6564	BS	t	173	t
494	1	1913085298	3	21	2026-11-14 14:37:08.052267+00	0.2958	FT	f	102	t
492	1	1913085298	3	18	2026-11-14 14:36:56.538468+00	0.2117	FT	f	144	t
484	1	1913085298	3	19	2026-11-14 14:32:47.691211+00	0.5431	BS	f	82	t
480	1	1913085298	3	20	2026-11-14 14:32:24.482177+00	0.727	BS	f	65	t
559	1	1913085298	3	15	2026-11-14 14:47:33.253833+00	0.8434	BS	f	145	t
555	1	1913085298	3	19	2026-11-14 14:47:10.441215+00	0.7752	BS	f	82	t
553	1	1913085298	3	21	2026-11-14 14:46:58.450191+00	0.9802	BS	f	60	t
538	1	1913085298	3	20	2026-11-14 14:45:35.432767+00	0.8896	BS	t	136	t
532	1	1913085298	3	17	2026-11-14 14:45:01.363843+00	0.5007	BS	f	99	t
518	1	1913085298	3	19	2026-11-14 14:43:42.450129+00	0.2723	FT	f	140	t
516	1	1913085298	3	16	2026-11-14 14:43:31.096602+00	0.6945	BS	f	132	t
514	1	1913085298	3	21	2026-11-14 14:43:19.813382+00	0.5371	BS	f	60	t
512	1	1913085298	3	18	2026-11-14 14:42:24.264042+00	0.8886	BS	t	178	t
510	1	1913085298	3	21	2026-11-14 14:42:12.415856+00	0.8713	BS	f	60	t
373	1	1629242254	3	20	2026-11-14 13:50:42.448297+00	0.3199	FT	f	110	t
371	1	1629242254	3	21	2026-11-14 13:50:36.915582+00	0.7789	BS	t	126	t
369	1	1629242254	3	18	2026-11-14 13:50:31.513119+00	0.2004	FT	t	303	t
356	1	1629242254	3	21	2026-11-14 13:48:39.860508+00	0.5786	BS	t	126	t
354	1	1629242254	3	18	2026-11-14 13:48:28.600245+00	0.4419	WW	f	110	t
351	1	1629242254	3	19	2026-11-14 13:48:10.964734+00	0.4849	BS	t	173	t
349	1	1629242254	3	17	2026-11-14 13:48:04.70386+00	0.4442	WW	f	128	t
399	1	1448305237	3	18	2026-11-14 13:54:33.577763+00	0.8139	BS	t	178	t
223	1	1448305237	3	10	2026-11-14 13:28:44.665486+00	0.274	FT	t	1160	t
246	1	1448305237	3	15	2026-11-14 13:31:59.000581+00	0.1016	MW	t	700	t
243	1	1448305237	3	16	2026-11-14 13:31:41.127624+00	0.907	BS	f	132	t
239	1	1448305237	3	15	2026-11-14 13:31:17.477361+00	0.9453	BS	f	145	t
235	1	1448305237	3	19	2026-11-14 13:30:51.615664+00	0.7019	BS	f	82	t
231	1	1448305237	3	20	2026-11-14 13:30:23.019601+00	0.9236	BS	t	136	t
227	1	1448305237	3	20	2026-11-14 13:29:57.856001+00	0.0652	FN	f	188	t
225	1	1448305237	3	17	2026-11-14 13:29:45.472882+00	0.8455	BS	t	207	t
1	1	965425988	1	2	2026-11-11 11:18:57.478681+00	\N	\N	f	\N	t
2	1	965425988	1	1	2026-11-11 11:19:13.421134+00	\N	\N	f	\N	t
3	1	965425988	1	1	2026-11-11 11:27:02.20038+00	\N	\N	f	\N	t
4	1	965425988	1	1	2026-11-11 11:27:10.898371+00	\N	\N	f	\N	t
5	1	965425988	1	1	2026-11-11 12:06:23.251104+00	\N	\N	f	\N	t
6	1	965425988	1	1	2026-11-11 12:06:30.819443+00	\N	\N	f	\N	t
7	1	965425988	2	6	2026-11-11 12:06:36.170279+00	\N	\N	f	\N	t
8	1	965425988	2	7	2026-11-11 12:06:42.49228+00	\N	\N	f	\N	t
9	1	965425988	3	10	2026-11-11 12:31:31.15227+00	\N	\N	f	\N	t
10	1	965425988	3	10	2026-11-11 12:31:41.030042+00	\N	\N	f	\N	t
11	1	965425988	3	10	2026-11-11 12:32:00.21961+00	\N	\N	f	\N	t
12	1	965425988	3	10	2026-11-11 12:32:09.834357+00	\N	\N	f	\N	t
13	1	965425988	3	10	2026-11-11 12:32:15.809002+00	\N	\N	f	\N	t
14	1	965425988	3	9	2026-11-11 12:32:24.242493+00	\N	\N	f	\N	t
15	1	965425988	1	2	2026-11-11 12:35:25.627493+00	\N	\N	f	\N	t
16	1	965425988	3	9	2026-11-11 12:58:52.670454+00	\N	\N	f	\N	t
17	1	965425988	3	10	2026-11-11 12:58:58.86742+00	\N	\N	f	\N	t
18	1	965425988	3	10	2026-11-11 12:59:04.831682+00	\N	\N	f	\N	t
19	1	965425988	3	10	2026-11-11 12:59:12.592603+00	\N	\N	f	\N	t
20	1	965425988	3	10	2026-11-11 12:59:18.272611+00	\N	\N	f	\N	t
21	1	965425988	3	10	2026-11-11 12:59:23.806918+00	\N	\N	f	\N	t
22	1	965425988	3	9	2026-11-11 13:07:12.975873+00	\N	\N	f	\N	t
23	1	965425988	3	11	2026-11-11 13:07:19.036356+00	\N	\N	f	\N	t
24	1	965425988	3	10	2026-11-11 13:09:13.439562+00	\N	\N	f	\N	t
25	1	965425988	3	12	2026-11-11 13:09:20.165443+00	\N	\N	f	\N	t
26	1	965425988	3	11	2026-11-11 13:09:25.745464+00	\N	\N	f	\N	t
27	1	965425988	3	12	2026-11-11 13:11:03.680622+00	\N	\N	f	\N	t
28	1	965425988	3	9	2026-11-11 18:35:43.858997+00	\N	\N	f	\N	t
29	1	965425988	2	6	2026-11-11 18:59:13.225653+00	\N	\N	f	\N	t
30	1	965425988	2	6	2026-11-11 18:59:19.106133+00	\N	\N	f	\N	t
31	1	965425988	2	5	2026-11-11 18:59:24.760016+00	\N	\N	f	\N	t
32	1	965425988	2	5	2026-11-11 18:59:30.474302+00	\N	\N	f	\N	t
33	1	965425988	2	8	2026-11-11 19:01:52.591539+00	\N	\N	f	\N	t
34	1	965425988	3	10	2026-11-11 19:02:40.838462+00	\N	\N	f	\N	t
35	1	965425988	3	10	2026-11-11 19:04:45.099655+00	\N	\N	f	\N	t
36	1	965425988	3	9	2026-11-11 19:06:54.587631+00	\N	\N	f	\N	t
37	1	965425988	2	6	2026-11-11 19:07:20.064176+00	\N	\N	f	\N	t
38	1	965425988	3	10	2026-11-11 19:32:37.509073+00	\N	\N	f	\N	t
39	1	965425988	1	1	2026-11-11 19:32:43.305984+00	\N	\N	f	\N	t
40	1	965425988	2	5	2026-11-11 19:32:49.098798+00	\N	\N	f	\N	t
41	1	965425988	2	5	2026-11-11 19:32:55.493179+00	\N	\N	f	\N	t
42	1	483243639	1	1	2026-11-11 19:35:58.080536+00	\N	\N	f	\N	t
43	1	483243639	3	10	2026-11-11 19:36:05.06966+00	\N	\N	f	\N	t
44	1	483243639	1	2	2026-11-11 19:36:13.708655+00	\N	\N	f	\N	t
45	1	483243639	1	1	2026-11-11 19:36:22.156396+00	\N	\N	f	\N	t
46	1	483243639	1	1	2026-11-11 19:36:28.135558+00	\N	\N	f	\N	t
47	1	483243639	3	10	2026-11-11 19:36:36.696638+00	\N	\N	f	\N	t
48	1	965425988	1	2	2026-11-11 19:36:53.429183+00	\N	\N	f	\N	t
49	1	965425988	2	6	2026-11-11 20:38:07.973318+00	\N	\N	f	\N	t
50	1	965425988	3	10	2026-11-11 20:43:07.879175+00	\N	\N	f	\N	t
51	1	965425988	3	10	2026-11-11 21:06:25.503264+00	\N	\N	f	\N	t
52	1	965425988	2	6	2026-11-11 21:06:32.736427+00	\N	\N	f	\N	t
53	1	965425988	3	10	2026-11-11 22:00:09.52673+00	\N	\N	f	\N	t
54	1	965425988	3	9	2026-11-11 22:00:15.897154+00	\N	\N	f	\N	t
55	1	965425988	3	10	2026-11-11 22:00:22.397468+00	\N	\N	f	\N	t
56	1	965425988	3	10	2026-11-11 22:00:29.244015+00	\N	\N	f	\N	t
57	1	965425988	3	9	2026-11-11 22:00:35.016297+00	\N	\N	f	\N	t
58	1	965425988	3	10	2026-11-11 22:04:02.540899+00	\N	\N	f	\N	t
59	1	965425988	3	10	2026-11-11 22:04:41.90848+00	\N	\N	f	\N	t
60	1	965425988	3	10	2026-11-11 22:04:51.582531+00	\N	\N	f	\N	t
61	1	965425988	3	9	2026-11-11 22:04:57.426906+00	\N	\N	f	\N	t
62	1	965425988	3	9	2026-11-11 22:14:01.760636+00	\N	\N	f	\N	t
63	1	965425988	3	9	2026-11-11 22:14:13.339397+00	\N	\N	f	\N	t
64	1	483243639	1	1	2026-11-11 22:25:44.929804+00	\N	\N	f	\N	t
65	1	483243639	1	1	2026-11-11 22:25:52.392595+00	\N	\N	f	\N	t
66	1	483243639	3	10	2026-11-11 22:25:58.577124+00	\N	\N	f	\N	t
67	1	965425988	3	9	2026-11-12 09:48:41.121569+00	\N	\N	f	\N	t
68	1	965425988	3	10	2026-11-12 09:52:22.500636+00	\N	\N	f	\N	t
69	1	8800648129	3	10	2026-11-12 10:10:03.200345+00	\N	\N	f	\N	t
70	1	8800648129	3	9	2026-11-12 10:21:32.843757+00	\N	\N	f	\N	t
71	1	965425988	3	10	2026-11-12 11:49:28.507264+00	\N	\N	f	\N	t
72	1	8800648129	2	5	2026-11-12 11:52:12.688859+00	\N	\N	f	\N	t
207	1	1629242254	3	20	2026-11-14 11:29:22.759449+00	0.5484	BS	t	136	t
315	1	1448305237	3	20	2026-11-14 13:46:12.146671+00	0.7043	BS	t	136	t
313	1	1448305237	3	18	2026-11-14 13:46:06.012126+00	0.9756	BS	t	178	t
311	1	1448305237	3	18	2026-11-14 13:46:00.447643+00	0.9533	BS	f	85	t
309	1	1448305237	3	13	2026-11-14 13:45:53.964165+00	0.8925	BS	f	600	t
298	1	1448305237	3	20	2026-11-14 13:44:42.209677+00	0.9277	BS	f	65	t
296	1	1448305237	3	16	2026-11-14 13:44:30.436036+00	0.2548	FT	t	471	t
294	1	1448305237	3	19	2026-11-14 13:44:15.651223+00	0.091	MW	t	398	t
292	1	1448305237	3	21	2026-11-14 13:44:04.47391+00	0.0106	FN	t	365	t
279	1	1448305237	3	14	2026-11-14 13:42:45.552155+00	0.3346	FT	f	408	t
277	1	1448305237	3	21	2026-11-14 13:42:33.744888+00	0.9364	BS	f	60	t
221	1	965425988	3	16	2026-11-14 13:22:33.95502+00	0.3413	FT	f	224	t
220	1	965425988	3	18	2026-11-14 13:22:28.540051+00	0.1158	MW	t	410	t
73	1	965425988	3	10	2026-11-12 13:27:24.889679+00	\N	\N	f	\N	t
74	1	965425988	3	10	2026-11-12 13:28:12.118457+00	\N	\N	f	\N	t
75	1	965425988	3	15	2026-11-12 15:09:22.367311+00	\N	\N	f	\N	t
76	1	8800648129	3	18	2026-11-12 15:30:10.734641+00	\N	\N	f	\N	t
77	1	8800648129	3	18	2026-11-12 15:30:16.780617+00	\N	\N	f	\N	t
78	1	8800648129	3	19	2026-11-12 15:30:22.069682+00	\N	\N	f	\N	t
79	1	8800648129	3	9	2026-11-12 15:30:27.721478+00	\N	\N	f	\N	t
80	1	1629242254	3	16	2026-11-12 15:45:28.026854+00	\N	\N	f	\N	t
81	1	1629242254	3	20	2026-11-12 15:45:36.876687+00	\N	\N	f	\N	t
82	1	1629242254	3	18	2026-11-12 15:45:47.402731+00	\N	\N	f	\N	t
83	1	1629242254	3	20	2026-11-12 15:48:37.759177+00	\N	\N	f	\N	t
84	1	1629242254	3	20	2026-11-12 15:48:43.763282+00	\N	\N	f	\N	t
85	1	1629242254	3	19	2026-11-12 15:48:49.430423+00	\N	\N	f	\N	t
86	1	1629242254	3	19	2026-11-12 15:48:55.108429+00	\N	\N	f	\N	t
87	1	1629242254	3	20	2026-11-12 15:49:00.634341+00	\N	\N	f	\N	t
88	1	1448305237	3	15	2026-11-12 16:03:25.688775+00	\N	\N	f	\N	t
89	1	1448305237	3	15	2026-11-12 16:03:45.29617+00	\N	\N	f	\N	t
90	1	1448305237	3	19	2026-11-12 16:03:56.743121+00	\N	\N	f	\N	t
91	1	233835983	3	14	2026-11-12 16:05:26.888589+00	\N	\N	f	\N	t
92	1	233835983	3	18	2026-11-12 16:05:36.281662+00	\N	\N	f	\N	t
93	1	233835983	3	19	2026-11-12 16:05:43.782145+00	\N	\N	f	\N	t
94	1	233835983	3	18	2026-11-12 16:05:49.729774+00	\N	\N	f	\N	t
95	1	233835983	3	14	2026-11-12 16:05:56.59735+00	\N	\N	f	\N	t
96	1	8793965959	3	18	2026-11-12 16:07:03.814435+00	\N	\N	f	\N	t
97	1	8793965959	3	20	2026-11-12 16:07:10.667325+00	\N	\N	f	\N	t
98	1	8793965959	3	19	2026-11-12 16:07:16.250956+00	\N	\N	f	\N	t
99	1	8793965959	3	17	2026-11-12 16:07:21.592885+00	\N	\N	f	\N	t
100	1	1448305237	3	20	2026-11-12 16:17:26.515629+00	\N	\N	f	\N	t
101	1	1448305237	3	20	2026-11-12 16:17:37.663231+00	\N	\N	f	\N	t
102	1	1448305237	3	18	2026-11-12 16:19:02.359788+00	\N	\N	f	\N	t
103	1	1913085298	3	18	2026-11-12 18:27:53.500033+00	\N	\N	f	\N	t
104	1	1913085298	3	21	2026-11-12 18:28:04.72057+00	\N	\N	f	\N	t
105	1	1913085298	3	20	2026-11-12 18:28:12.540582+00	\N	\N	f	\N	t
106	1	1913085298	3	18	2026-11-12 18:28:20.973014+00	\N	\N	f	\N	t
107	1	1913085298	3	18	2026-11-12 18:28:30.355549+00	\N	\N	f	\N	t
108	1	1913085298	3	19	2026-11-12 18:28:37.03905+00	\N	\N	f	\N	t
109	1	1913085298	3	18	2026-11-12 18:28:43.006543+00	\N	\N	f	\N	t
110	1	1913085298	3	21	2026-11-12 18:28:54.038341+00	\N	\N	f	\N	t
111	1	1913085298	3	13	2026-11-12 18:28:59.653233+00	\N	\N	f	\N	t
112	1	1913085298	3	16	2026-11-12 18:29:08.180981+00	\N	\N	f	\N	t
113	1	7756709710	3	18	2026-11-12 18:31:44.686754+00	\N	\N	f	\N	t
114	1	7756709710	3	21	2026-11-12 18:31:51.283876+00	\N	\N	f	\N	t
115	1	7756709710	3	20	2026-11-12 18:31:56.720181+00	\N	\N	f	\N	t
116	1	7756709710	3	20	2026-11-12 18:32:02.296637+00	\N	\N	f	\N	t
117	1	7756709710	3	21	2026-11-12 18:32:07.92525+00	\N	\N	f	\N	t
118	1	7756709710	3	17	2026-11-12 18:32:13.39064+00	\N	\N	f	\N	t
119	1	7756709710	3	16	2026-11-12 18:32:18.928682+00	\N	\N	f	\N	t
120	1	7756709710	3	18	2026-11-12 18:32:24.528167+00	\N	\N	f	\N	t
129	1	1629242254	3	20	2026-11-12 18:52:49.772935+00	\N	\N	f	\N	t
134	1	1629242254	3	21	2026-11-12 18:53:20.053818+00	\N	\N	f	\N	t
139	1	233835983	3	16	2026-11-12 18:58:12.626696+00	\N	\N	f	\N	t
148	1	1629242254	3	20	2026-11-12 19:47:17.482757+00	\N	\N	f	\N	t
156	1	1629242254	3	14	2026-11-12 23:09:47.598064+00	\N	\N	f	\N	t
161	1	1629242254	3	14	2026-11-12 23:10:19.356507+00	\N	\N	f	\N	t
165	1	1913085298	3	19	2026-11-13 14:29:37.769536+00	\N	\N	f	\N	t
167	1	1913085298	3	21	2026-11-13 14:29:54.684234+00	\N	\N	f	\N	t
170	1	1913085298	3	19	2026-11-13 14:30:12.082266+00	\N	\N	f	\N	t
172	1	1913085298	3	20	2026-11-13 14:30:23.768039+00	\N	\N	f	\N	t
173	1	1913085298	3	17	2026-11-13 14:30:29.714168+00	\N	\N	f	\N	t
174	1	1913085298	3	20	2026-11-13 14:30:35.653828+00	\N	\N	f	\N	t
175	1	1913085298	3	21	2026-11-13 14:30:41.865492+00	\N	\N	f	\N	t
176	1	1913085298	3	15	2026-11-13 14:30:49.439894+00	\N	\N	f	\N	t
177	1	1913085298	3	20	2026-11-13 14:30:55.226948+00	\N	\N	f	\N	t
178	1	1913085298	3	18	2026-11-13 14:31:00.913515+00	\N	\N	f	\N	t
179	1	1913085298	3	15	2026-11-13 14:31:06.793994+00	\N	\N	f	\N	t
180	1	1913085298	3	19	2026-11-13 14:31:13.645537+00	\N	\N	f	\N	t
181	1	1913085298	3	19	2026-11-13 14:31:19.289062+00	\N	\N	f	\N	t
182	1	1913085298	3	21	2026-11-13 14:31:24.87946+00	\N	\N	f	\N	t
183	1	1913085298	3	20	2026-11-13 14:31:30.72853+00	\N	\N	f	\N	t
184	1	5714687590	3	21	2026-11-13 16:21:04.367241+00	\N	\N	f	\N	t
185	1	5714687590	3	20	2026-11-13 16:21:11.201703+00	\N	\N	f	\N	t
186	1	5714687590	3	21	2026-11-13 16:21:27.528164+00	\N	\N	f	\N	t
187	1	965425988	3	20	2026-11-13 22:39:53.384346+00	0.7619	BS	t	136	t
188	1	965425988	3	17	2026-11-13 22:40:02.369614+00	0.365	FT	f	168	t
189	1	965425988	3	17	2026-11-13 22:40:18.517833+00	0.1586	FT	t	353	t
190	1	965425988	3	20	2026-11-13 22:40:50.42439+00	0.734	BS	f	65	t
191	1	965425988	3	14	2026-11-13 22:41:03.658822+00	0.4665	BS	t	504	t
245	1	1448305237	3	20	2026-11-14 13:31:52.791994+00	0.4705	BS	t	136	t
242	1	1448305237	3	18	2026-11-14 13:31:35.39188+00	0.1656	FT	f	144	t
241	1	1448305237	3	18	2026-11-14 13:31:29.633328+00	0.8163	BS	t	178	t
238	1	1448305237	3	21	2026-11-14 13:31:10.209738+00	0.6146	BS	t	126	t
233	1	1448305237	3	14	2026-11-14 13:30:35.995609+00	0.5568	BS	t	504	t
230	1	1448305237	3	21	2026-11-14 13:30:16.90263+00	0.1644	FT	f	102	t
226	1	1448305237	3	18	2026-11-14 13:29:51.557075+00	0.316	FT	f	144	t
224	1	1448305237	3	18	2026-11-14 13:29:38.496613+00	0.8423	BS	t	178	t
310	1	1629242254	3	15	2026-11-14 13:45:57.546897+00	0.982	BS	t	304	t
210	1	1629242254	3	20	2026-11-14 11:29:47.596591+00	0.8773	BS	f	65	t
208	1	1629242254	3	20	2026-11-14 11:29:33.874708+00	0.6287	BS	f	65	t
297	1	1448305237	3	19	2026-11-14 13:44:36.168676+00	0.4909	BS	t	173	t
295	1	1448305237	3	21	2026-11-14 13:44:22.45111+00	0.8947	BS	f	60	t
293	1	1448305237	3	21	2026-11-14 13:44:10.016788+00	0.6419	BS	t	126	t
291	1	1448305237	3	20	2026-11-14 13:43:58.976917+00	0.1179	MW	t	313	t
278	1	1448305237	3	20	2026-11-14 13:42:39.604614+00	0.5829	BS	f	65	t
634	1	1913085298	3	19	2026-11-14 14:58:32.264733+00	0.7104	BS	f	82	t
615	1	1913085298	3	16	2026-11-14 14:54:29.009264+00	0.3338	FT	t	471	t
617	1	1913085298	3	15	2026-11-14 14:54:40.298009+00	0.7461	BS	f	145	t
627	1	1913085298	3	21	2026-11-14 14:56:16.185127+00	0.4096	WW	f	78	t
632	1	1913085298	3	16	2026-11-14 14:57:55.402629+00	0.8055	BS	f	132	t
641	1	1913085298	3	15	2026-11-14 15:00:12.056176+00	0.7038	BS	t	304	t
652	1	1913085298	3	19	2026-11-14 15:01:59.406343+00	0.019	FN	f	239	t
654	1	1448305237	4	22	2026-11-14 15:04:21.548362+00	0.4571	BS	t	31172	t
655	1	1448305237	4	22	2026-11-14 15:04:38.121441+00	0.6388	BS	f	14844	t
660	1	1913085298	4	22	2026-11-14 15:05:32.313308+00	0.1187	MW	t	71696	t
662	1	1913085298	4	22	2026-11-14 15:05:44.226023+00	0.1573	FT	t	52993	t
667	1	1448305237	4	22	2026-11-14 15:06:12.023571+00	0.1865	FT	t	52993	t
669	1	1448305237	4	22	2026-11-14 15:06:17.654823+00	0.6489	BS	t	31172	t
671	1	1448305237	4	22	2026-11-14 15:06:25.36797+00	0.0659	FN	f	43047	t
673	1	1448305237	4	22	2026-11-14 15:06:31.20631+00	0.2493	FT	f	25234	t
675	1	1448305237	4	22	2026-11-14 15:06:41.57806+00	0.2126	FT	f	25234	t
680	1	1913085298	4	22	2026-11-14 15:07:24.9442+00	0.7181	BS	f	14844	t
682	1	1913085298	4	22	2026-11-14 15:08:24.424452+00	0.7325	BS	f	14844	t
683	1	1913085298	4	22	2026-11-14 15:08:49.404023+00	0.0761	MW	t	71696	t
651	1	1913085298	3	18	2026-11-14 15:01:53.743264+00	0.8955	BS	f	85	t
687	1	1913085298	4	22	2026-11-14 15:10:15.561517+00	0.1861	FT	f	25234	t
686	1	1913085298	4	22	2026-11-14 15:09:34.181368+00	0.5278	BS	t	31172	t
616	1	1913085298	3	15	2026-11-14 14:54:34.686126+00	0.9043	BS	f	145	t
618	1	1913085298	3	15	2026-11-14 14:54:45.878461+00	0.808	BS	t	304	t
626	1	1913085298	3	10	2026-11-14 14:55:58.744004+00	0.7692	BS	t	682	t
628	1	1913085298	3	19	2026-11-14 14:56:45.121741+00	0.6705	BS	t	173	t
633	1	1913085298	3	20	2026-11-14 14:58:21.848846+00	0.0773	MW	t	313	t
642	1	1913085298	3	17	2026-11-14 15:00:27.968296+00	0.8325	BS	t	207	t
656	1	1448305237	4	22	2026-11-14 15:04:52.468212+00	0.2821	FT	f	25234	t
658	1	1448305237	4	22	2026-11-14 15:05:05.198361+00	0.4131	WW	t	40524	t
661	1	1913085298	4	22	2026-11-14 15:05:38.103085+00	0.8269	BS	f	14844	t
668	1	1913085298	4	22	2026-11-14 15:06:12.335572+00	0.3644	FT	f	25234	t
670	1	1913085298	4	22	2026-11-14 15:06:22.23764+00	0.4792	BS	f	14844	t
672	1	1913085298	4	22	2026-11-14 15:06:27.864609+00	0.0628	FN	t	90399	t
674	1	1913085298	4	22	2026-11-14 15:06:33.360358+00	0.8157	BS	t	31172	t
649	1	1913085298	3	21	2026-11-14 15:01:41.208978+00	0.4465	WW	t	163	t
645	1	1913085298	3	20	2026-11-14 15:01:17.512186+00	0.7384	BS	f	65	t
643	1	1913085298	3	19	2026-11-14 15:01:03.028296+00	0.9751	BS	f	82	t
640	1	1913085298	3	19	2026-11-14 14:59:47.844894+00	0.6986	BS	t	173	t
638	1	1913085298	3	19	2026-11-14 14:59:25.375155+00	0.3026	FT	f	140	t
684	1	1913085298	4	22	2026-11-14 15:09:04.942737+00	0.7233	BS	f	14844	t
619	1	1913085298	3	18	2026-11-14 14:54:51.75234+00	0.4824	BS	f	85	t
621	1	1913085298	3	20	2026-11-14 14:55:03.0808+00	0.7443	BS	t	136	t
623	1	1913085298	3	17	2026-11-14 14:55:15.906318+00	0.446	WW	t	270	t
624	1	1913085298	3	15	2026-11-14 14:55:21.908887+00	0.0492	FN	t	883	t
629	1	1913085298	3	16	2026-11-14 14:56:55.791111+00	0.9863	BS	f	132	t
631	1	1913085298	3	20	2026-11-14 14:57:42.452554+00	0.7719	BS	t	136	t
636	1	1913085298	3	14	2026-11-14 14:59:02.732123+00	0.7295	BS	f	240	t
646	1	1913085298	3	14	2026-11-14 15:01:23.327169+00	0.5066	BS	f	240	t
653	1	1448305237	4	22	2026-11-14 15:04:15.190932+00	0.1832	FT	f	25234	t
663	1	1913085298	4	22	2026-11-14 15:05:50.190624+00	0.1541	FT	t	52993	t
666	1	1913085298	4	22	2026-11-14 15:06:06.598964+00	0.5703	BS	t	31172	t
676	1	1913085298	4	22	2026-11-14 15:06:52.65978+00	0.2568	FT	f	25234	t
679	1	1913085298	4	22	2026-11-14 15:07:12.012847+00	0.0168	FN	t	90399	t
647	1	1913085298	3	19	2026-11-14 15:01:29.330781+00	0.5107	BS	f	82	t
635	1	1913085298	3	20	2026-11-14 14:58:53.988288+00	0.2679	FT	f	110	t
657	1	1913085298	4	22	2026-11-14 15:04:52.563293+00	0.1283	MW	t	71696	t
701	1	1913085298	4	22	2026-11-14 15:27:18.003206+00	0.7584	BS	f	14844	t
700	1	1913085298	4	22	2026-11-14 15:27:12.528775+00	0.1099	MW	f	34141	t
699	1	1913085298	4	22	2026-11-14 15:27:06.184524+00	0.8622	BS	f	14844	t
695	1	1913085298	4	22	2026-11-14 15:26:28.950541+00	0.9204	BS	f	14844	t
697	1	1913085298	4	22	2026-11-14 15:26:40.333386+00	0.3848	WW	t	40524	t
694	1	1913085298	4	22	2026-11-14 15:26:23.270391+00	0.9759	BS	t	31172	t
692	1	1913085298	4	22	2026-11-14 15:26:11.922341+00	0.7292	BS	f	14844	t
690	1	1913085298	4	22	2026-11-14 15:11:23.178739+00	0.5819	BS	t	31172	t
688	1	1913085298	4	22	2026-11-14 15:10:21.487074+00	0.9204	BS	t	31172	t
728	1	1629242254	4	27	2026-11-14 16:18:12.914845+00	0.0308	FN	t	11647	t
727	1	1629242254	4	22	2026-11-14 16:11:04.475276+00	0.1416	MW	f	34141	t
620	1	1913085298	3	20	2026-11-14 14:54:57.745947+00	0.1796	FT	f	110	t
757	1	1448305237	4	29	2026-11-14 17:00:34.589021+00	0.9404	BS	t	2165	t
759	1	1448305237	4	24	2026-11-14 17:00:46.204159+00	0.7646	BS	f	2141	t
772	1	1448305237	4	30	2026-11-14 17:01:59.15199+00	0.7411	BS	t	5506	t
774	1	1448305237	4	29	2026-11-14 17:02:14.273237+00	0.1934	FT	t	3680	t
776	1	1448305237	4	30	2026-11-14 17:02:25.502725+00	0.477	BS	t	5506	t
778	1	1448305237	4	27	2026-11-14 17:02:36.48507+00	0.6959	BS	f	1912	t
780	1	1448305237	4	22	2026-11-14 17:02:47.565348+00	0.328	FT	t	52993	t
793	1	1448305237	4	33	2026-11-14 19:23:17.428571+00	0.8008	BS	f	930	t
758	1	1448305237	4	22	2026-11-14 17:00:40.14912+00	0.3327	FT	f	25234	t
771	1	1448305237	4	25	2026-11-14 17:01:53.556184+00	0.174	FT	t	22023	t
773	1	1448305237	4	23	2026-11-14 17:02:08.622567+00	0.1948	FT	t	36903	t
775	1	1448305237	4	24	2026-11-14 17:02:20.011221+00	0.9745	BS	t	4497	t
777	1	1448305237	4	27	2026-11-14 17:02:30.942727+00	0.0664	FN	t	11647	t
779	1	1448305237	4	22	2026-11-14 17:02:42.010575+00	0.0828	MW	t	71696	t
792	1	1448305237	4	30	2026-11-14 19:23:11.947104+00	0.0468	FN	t	15967	t
797	1	1448305237	4	33	2026-11-14 19:23:44.860312+00	0.9922	BS	f	930	t
785	1	1448305237	4	27	2026-11-14 17:03:14.841239+00	0.5051	BS	t	4016	t
760	1	1448305237	4	30	2026-11-14 17:00:51.736658+00	0.411	WW	f	3408	t
762	1	1448305237	4	24	2026-11-14 17:01:02.767105+00	0.582	BS	f	2141	t
764	1	1448305237	4	25	2026-11-14 17:01:14.094541+00	0.677	BS	t	12954	t
766	1	1448305237	4	30	2026-11-14 17:01:25.391901+00	0.7258	BS	f	2622	t
768	1	1448305237	4	25	2026-11-14 17:01:36.887576+00	0.2234	FT	t	22023	t
770	1	1448305237	4	31	2026-11-14 17:01:47.932671+00	0.1356	MW	f	5677	t
781	1	1448305237	4	27	2026-11-14 17:02:53.00399+00	0.7442	BS	f	1912	t
783	1	1448305237	4	27	2026-11-14 17:03:03.840798+00	0.0532	FN	f	5546	t
788	1	1448305237	4	34	2026-11-14 19:22:49.708741+00	0.8615	BS	t	6948	t
790	1	1448305237	4	37	2026-11-14 19:23:00.861292+00	0.8473	BS	t	1019	t
795	1	1448305237	4	24	2026-11-14 19:23:28.435256+00	0.4922	BS	t	4497	t
784	1	1448305237	4	28	2026-11-14 17:03:09.33226+00	0.9046	BS	f	2129	t
730	1	1629242254	4	26	2026-11-14 16:18:19.957038+00	0.5088	BS	t	6895	t
375	1	1629242254	3	19	2026-11-14 13:50:47.875555+00	0.9349	BS	t	173	t
362	1	1629242254	3	18	2026-11-14 13:49:12.797536+00	0.6784	BS	t	178	t
823	1	7387068552	4	25	2026-11-15 04:25:37.74689+00	0.1337	MW	f	3415	t
824	1	7387068552	4	47	2026-11-15 04:27:30.331653+00	0.0203	FN	t	73	t
828	1	7387068552	4	30	2026-11-15 04:27:54.976786+00	0.2655	FT	t	838	t
826	1	7387068552	4	24	2026-11-15 04:27:42.05927+00	0.7075	BS	t	2551	t
827	1	7387068552	4	38	2026-11-15 04:27:48.979861+00	0.378	FT	f	5485	t
825	1	7387068552	4	46	2026-11-15 04:27:36.345995+00	0.0808	MW	f	34	t
832	1	7387068552	4	33	2026-11-15 04:28:17.772739+00	0.2002	FT	t	3321	t
831	1	7387068552	4	40	2026-11-15 04:28:12.215061+00	0.0687	FN	t	2582	t
834	1	7387068552	4	39	2026-11-15 04:28:28.940691+00	0.2396	FT	t	6326	t
833	1	7387068552	4	44	2026-11-15 04:28:23.435065+00	0.4386	WW	f	220	t
836	1	7387068552	4	43	2026-11-15 04:28:40.333444+00	0.4736	BS	t	180	t
835	1	7387068552	4	37	2026-11-15 04:28:34.711072+00	0.6476	BS	f	485	t
830	1	7387068552	4	43	2026-11-15 04:28:06.498747+00	0.3987	WW	t	234	t
829	1	7387068552	4	41	2026-11-15 04:28:00.644579+00	0.2724	FT	t	465	t
840	1	1448305237	4	25	2026-11-15 04:42:57.807206+00	0.0994	MW	t	7172	t
842	1	1448305237	4	36	2026-11-15 04:43:13.941226+00	0.4315	WW	t	1419	t
841	1	1448305237	4	42	2026-11-15 04:43:08.217966+00	0.2073	FT	f	117	t
839	1	1448305237	4	44	2026-11-15 04:42:52.140274+00	0.7455	BS	t	153	t
838	1	1448305237	4	33	2026-11-15 04:42:45.351224+00	0.9154	BS	f	175	t
867	1	1448305237	5	54	2026-11-15 05:51:56.022908+00	0.3011	FT	f	1346	t
866	1	1448305237	5	72	2026-11-15 05:51:50.295331+00	0.7798	BS	f	15	t
865	1	1448305237	5	53	2026-11-15 05:46:33.109808+00	0.3942	WW	t	2755	t
864	1	1448305237	4	42	2026-11-15 04:52:30.418121+00	0.0328	FN	f	200	t
761	1	1448305237	4	26	2026-11-14 17:00:57.235667+00	0.6483	BS	t	6895	t
872	1	1448305237	5	62	2026-11-15 06:19:19.144643+00	0.123	MW	f	196	t
869	1	1448305237	5	63	2026-11-15 05:52:07.874902+00	0.8595	BS	t	351	t
870	1	1448305237	5	59	2026-11-15 06:19:06.692478+00	0.7028	BS	f	396	t
871	1	1448305237	5	66	2026-11-15 06:19:13.182775+00	0.4361	WW	t	529	t
873	1	1448305237	5	60	2026-11-15 06:19:24.653676+00	0.1253	MW	f	309	t
879	1	1448305237	7	121	2026-11-15 16:07:02.449427+00	0.3873	WW	f	14	t
878	1	1448305237	7	110	2026-11-15 16:06:56.643212+00	0.1362	MW	f	59	t
877	1	1448305237	7	111	2026-11-15 16:06:50.438214+00	0.5367	BS	t	27	t
874	1	1448305237	5	60	2026-11-15 06:19:30.482817+00	0.9773	BS	t	282	t
889	1	1448305237	8	133	2026-11-16 10:06:32.843831+00	0.4228	WW	f	22	t
888	1	1448305237	8	134	2026-11-16 10:06:27.225752+00	0.5763	BS	f	22	t
887	1	1448305237	8	133	2026-11-16 10:06:21.740445+00	0.6242	BS	t	36	t
886	1	1448305237	8	132	2026-11-16 10:06:16.275404+00	0.4908	BS	t	61	t
885	1	1448305237	8	132	2026-11-16 10:06:10.627587+00	0.8668	BS	f	29	t
884	1	1448305237	8	139	2026-11-16 10:06:05.207364+00	0.6568	BS	f	24	t
883	1	1448305237	8	137	2026-11-16 10:05:59.705068+00	0.0551	FN	f	117	t
882	1	1448305237	8	130	2026-11-16 10:05:54.054432+00	0.3919	WW	t	204	t
881	1	1448305237	8	136	2026-11-16 10:05:47.935267+00	0.4597	BS	t	89	t
880	1	1448305237	8	131	2026-11-16 10:05:42.203126+00	0.7644	BS	t	89	t
868	1	1448305237	5	67	2026-11-15 05:52:02.271786+00	0.8144	BS	f	85	t
909	1	965425988	3	21	2026-11-17 09:59:12.89778+00	0.5902	BS	t	126	t
910	1	965425988	3	20	2026-11-17 09:59:35.398277+00	0.5868	BS	t	136	t
911	1	965425988	3	16	2026-11-17 09:59:55.708527+00	0.3878	WW	t	360	t
912	1	965425988	3	19	2026-11-17 10:00:30.502955+00	0.7945	BS	f	82	t
913	1	965425988	3	19	2026-11-17 10:01:03.099644+00	0.4284	WW	t	225	t
915	1	1448305237	9	154	2026-11-17 11:18:26.179462+00	0.8503	BS	f	31	t
916	1	1448305237	9	162	2026-11-17 11:18:39.097598+00	0.8247	BS	t	102	t
917	1	1629242254	9	158	2026-11-17 14:22:16.952067+00	0.4135	WW	t	105	t
918	1	1629242254	9	168	2026-11-17 14:22:27.474016+00	0.9385	BS	t	24	t
199	1	1170057607	3	17	2026-11-13 23:10:38.788826+00	0.0417	FN	t	602	t
402	1	1448305237	3	16	2026-11-14 13:54:50.502457+00	0.1467	MW	t	637	t
407	1	1448305237	3	17	2026-11-14 13:55:18.071209+00	0.1941	FT	t	353	t
409	1	1448305237	3	19	2026-11-14 13:55:29.487673+00	0.5436	BS	f	82	t
411	1	1448305237	3	21	2026-11-14 13:55:40.500408+00	0.4618	BS	t	126	t
422	1	1448305237	3	21	2026-11-14 13:56:52.902574+00	0.5679	BS	t	126	t
424	1	1448305237	3	16	2026-11-14 13:57:06.901003+00	0.6969	BS	f	132	t
426	1	1448305237	3	21	2026-11-14 13:57:18.156809+00	0.9929	BS	t	126	t
428	1	1448305237	3	21	2026-11-14 13:57:29.547804+00	0.5437	BS	f	60	t
430	1	1448305237	3	19	2026-11-14 13:57:40.491306+00	0.9896	BS	t	173	t
440	1	8793965959	3	18	2026-11-14 13:59:47.037448+00	0.925	BS	f	85	t
445	1	1448305237	3	17	2026-11-14 14:00:44.332784+00	0.0796	MW	t	478	t
457	1	1448305237	3	19	2026-11-14 14:01:59.158738+00	0.2552	FT	t	294	t
459	1	1448305237	3	19	2026-11-14 14:02:10.354398+00	0.8015	BS	t	173	t
461	1	1448305237	3	18	2026-11-14 14:02:21.443586+00	0.8508	BS	t	178	t
463	1	1448305237	3	21	2026-11-14 14:02:32.37617+00	0.1238	MW	t	289	t
465	1	1448305237	3	20	2026-11-14 14:02:43.600047+00	0.5747	BS	t	136	t
473	1	1448305237	3	14	2026-11-14 14:03:45.604038+00	0.9243	BS	f	240	t
497	1	1913085298	3	13	2026-11-14 14:37:25.258596+00	0.9235	BS	t	1260	t
875	1	1629242254	4	32	2026-11-15 13:47:43.821899+00	0.4821	BS	t	651	t
876	1	1629242254	4	47	2026-11-15 13:47:49.40588+00	0.6816	BS	f	12	t
890	1	965425988	9	163	2026-11-16 20:05:54.050971+00	0.3388	FT	t	166	t
891	1	1448305237	9	151	2026-11-17 07:57:13.494171+00	0.9883	BS	f	99	t
892	1	1448305237	9	153	2026-11-17 07:57:19.348361+00	0.1988	FT	f	32	t
893	1	1448305237	9	162	2026-11-17 07:57:25.008937+00	0.8375	BS	t	102	t
894	1	1448305237	9	153	2026-11-17 07:57:31.038201+00	0.0182	FN	t	115	t
895	1	1448305237	9	167	2026-11-17 07:57:37.158791+00	0.6872	BS	t	518	t
896	1	1448305237	9	150	2026-11-17 07:57:46.891408+00	0.595	BS	f	26	t
897	1	1448305237	9	168	2026-11-17 07:57:52.697402+00	0.8945	BS	f	11	t
898	1	1448305237	9	154	2026-11-17 07:57:58.444782+00	0.0761	MW	f	72	t
899	1	1448305237	9	158	2026-11-17 07:58:04.329201+00	0.6624	BS	f	38	t
900	1	1448305237	9	153	2026-11-17 07:58:09.985902+00	0.6451	BS	t	39	t
901	1	1448305237	9	160	2026-11-17 07:58:15.579995+00	0.8909	BS	t	59	t
902	1	1448305237	5	72	2026-11-17 07:58:45.316175+00	0.5171	BS	f	15	t
903	1	1448305237	5	62	2026-11-17 07:58:50.957692+00	0.3191	FT	f	145	t
904	1	1448305237	5	63	2026-11-17 07:58:56.770328+00	0.2436	FT	t	597	t
905	1	1448305237	5	52	2026-11-17 07:59:02.453296+00	0.9112	BS	t	2536	t
906	1	1448305237	5	52	2026-11-17 07:59:08.281116+00	0.291	FT	t	4312	t
907	1	1448305237	5	70	2026-11-17 07:59:14.957293+00	0.1342	MW	t	159	t
908	1	1448305237	5	71	2026-11-17 07:59:20.653654+00	0.6467	BS	t	57	t
914	1	1448305237	7	114	2026-11-17 11:18:11.038653+00	0.0262	FN	f	31	t
499	1	1913085298	3	19	2026-11-14 14:37:37.997782+00	0.3455	FT	t	294	t
501	1	1913085298	3	18	2026-11-14 14:37:49.880386+00	0.0941	MW	t	410	t
517	1	1913085298	3	10	2026-11-14 14:43:36.599633+00	0.8179	BS	t	682	t
587	1	1913085298	3	20	2026-11-14 14:51:48.64044+00	0.4624	BS	t	136	t
596	1	1913085298	3	17	2026-11-14 14:52:39.38157+00	0.8777	BS	t	207	t
597	1	1913085298	3	21	2026-11-14 14:52:44.883284+00	0.5192	BS	t	126	t
609	1	1913085298	3	19	2026-11-14 14:53:54.859458+00	0.9367	BS	f	82	t
610	1	1913085298	3	20	2026-11-14 14:54:00.638244+00	0.802	BS	f	65	t
611	1	1913085298	3	19	2026-11-14 14:54:06.247797+00	0.7833	BS	t	173	t
612	1	1913085298	3	21	2026-11-14 14:54:11.88686+00	0.4799	BS	f	60	t
408	1	1448305237	3	20	2026-11-14 13:55:23.93481+00	0.5945	BS	t	136	t
410	1	1448305237	3	20	2026-11-14 13:55:35.000553+00	0.3087	FT	t	232	t
412	1	1448305237	3	21	2026-11-14 13:55:45.879944+00	0.1449	MW	t	289	t
423	1	1448305237	3	18	2026-11-14 13:56:58.724455+00	0.3233	FT	t	303	t
425	1	1448305237	3	18	2026-11-14 13:57:12.528384+00	0.9817	BS	t	178	t
427	1	1448305237	3	20	2026-11-14 13:57:23.427324+00	0.603	BS	f	65	t
429	1	1448305237	3	15	2026-11-14 13:57:35.065962+00	0.9971	BS	f	145	t
431	1	1448305237	3	20	2026-11-14 13:57:47.624308+00	0.9241	BS	f	65	t
442	1	8793965959	3	19	2026-11-14 14:00:09.139793+00	0.353	FT	t	294	t
443	1	1448305237	3	17	2026-11-14 14:00:33.159682+00	0.5417	BS	f	99	t
447	1	1448305237	3	15	2026-11-14 14:01:02.975891+00	0.0369	FN	t	883	t
523	1	1913085298	3	10	2026-11-14 14:44:09.866716+00	0.1726	FT	t	1160	t
525	1	1913085298	3	20	2026-11-14 14:44:21.683237+00	0.2123	FT	t	232	t
529	1	1913085298	3	20	2026-11-14 14:44:44.17797+00	0.2181	FT	t	232	t
544	1	1913085298	3	20	2026-11-14 14:46:08.784179+00	0.0531	FN	t	395	t
548	1	1913085298	3	20	2026-11-14 14:46:30.988742+00	0.0353	FN	t	395	t
550	1	1913085298	3	17	2026-11-14 14:46:42.054538+00	0.7912	BS	t	207	t
563	1	1913085298	3	18	2026-11-14 14:47:55.581975+00	0.3367	FT	t	303	t
578	1	1913085298	3	17	2026-11-14 14:50:53.53824+00	0.4889	BS	f	99	t
580	1	1913085298	3	18	2026-11-14 14:51:08.487224+00	0.678	BS	t	178	t
582	1	1913085298	3	21	2026-11-14 14:51:20.45393+00	0.1552	FT	f	102	t
584	1	1913085298	3	19	2026-11-14 14:51:31.937822+00	0.7556	BS	t	173	t
586	1	1913085298	3	19	2026-11-14 14:51:43.074168+00	0.9268	BS	f	82	t
590	1	1913085298	3	19	2026-11-14 14:52:05.674079+00	0.2769	FT	f	140	t
594	1	1913085298	3	19	2026-11-14 14:52:28.153098+00	0.3071	FT	t	294	t
598	1	1913085298	3	19	2026-11-14 14:52:50.362805+00	0.9471	BS	f	82	t
600	1	1913085298	3	20	2026-11-14 14:53:02.570406+00	0.1017	MW	f	149	t
602	1	1913085298	3	16	2026-11-14 14:53:14.937607+00	0.3938	WW	t	360	t
604	1	1913085298	3	20	2026-11-14 14:53:26.267971+00	0.7934	BS	f	65	t
606	1	1913085298	3	19	2026-11-14 14:53:37.442186+00	0.8193	BS	t	173	t
218	1	965425988	3	18	2026-11-14 13:08:11.028502+00	0.2764	FT	f	144	t
448	1	1448305237	3	15	2026-11-14 14:01:08.734287+00	0.0964	MW	f	333	t
450	1	1448305237	3	20	2026-11-14 14:01:19.898721+00	0.4958	BS	t	136	t
452	1	1448305237	3	18	2026-11-14 14:01:31.617856+00	0.055	FN	f	246	t
454	1	1448305237	3	20	2026-11-14 14:01:42.730358+00	0.6962	BS	f	65	t
467	1	1448305237	3	15	2026-11-14 14:02:54.570242+00	0.8102	BS	t	304	t
469	1	1448305237	3	10	2026-11-14 14:03:05.732547+00	0.2338	FT	f	552	t
471	1	1448305237	3	20	2026-11-14 14:03:16.768782+00	0.8254	BS	t	136	t
489	1	1913085298	3	10	2026-11-14 14:36:36.963115+00	0.8284	BS	t	682	t
547	1	1913085298	3	21	2026-11-14 14:46:25.381932+00	0.1956	FT	t	214	t
551	1	1913085298	3	19	2026-11-14 14:46:47.656274+00	0.1885	FT	t	294	t
568	1	1913085298	3	21	2026-11-14 14:49:56.995616+00	0.5688	BS	t	126	t
570	1	1913085298	3	10	2026-11-14 14:50:07.987679+00	0.3328	FT	f	552	t
572	1	1913085298	3	20	2026-11-14 14:50:19.306857+00	0.6381	BS	f	65	t
574	1	1913085298	3	21	2026-11-14 14:50:30.881668+00	0.4154	WW	f	78	t
576	1	1913085298	3	20	2026-11-14 14:50:42.157492+00	0.5901	BS	t	136	t
589	1	1913085298	3	20	2026-11-14 14:51:59.933991+00	0.6621	BS	t	136	t
591	1	1913085298	3	18	2026-11-14 14:52:11.317109+00	0.7283	BS	f	85	t
592	1	1913085298	3	21	2026-11-14 14:52:16.92186+00	0.8565	BS	t	126	t
599	1	1913085298	3	19	2026-11-14 14:52:56.042019+00	0.2175	FT	t	294	t
601	1	1913085298	3	18	2026-11-14 14:53:09.021007+00	0.9671	BS	f	85	t
603	1	1913085298	3	19	2026-11-14 14:53:20.451791+00	0.1015	MW	f	189	t
605	1	1913085298	3	20	2026-11-14 14:53:31.815392+00	0.0684	FN	t	395	t
607	1	1913085298	3	19	2026-11-14 14:53:43.32433+00	0.9613	BS	f	82	t
608	1	1913085298	3	15	2026-11-14 14:53:49.100248+00	0.2942	FT	f	246	t
613	1	1913085298	3	19	2026-11-14 14:54:17.480061+00	0.2047	FT	t	294	t
614	1	1913085298	3	19	2026-11-14 14:54:23.202642+00	0.4163	WW	t	225	t
216	1	965425988	3	9	2026-11-14 13:07:41.66818+00	0.8633	BS	f	400	t
217	1	965425988	3	18	2026-11-14 13:07:55.246789+00	0.6885	BS	f	85	t
400	1	1448305237	3	9	2026-11-14 13:54:39.042287+00	0.9201	BS	f	400	t
406	1	1448305237	3	19	2026-11-14 13:55:12.492524+00	0.7967	BS	t	173	t
414	1	1448305237	3	20	2026-11-14 13:55:56.718311+00	0.2809	FT	t	232	t
416	1	1448305237	3	20	2026-11-14 13:56:07.850688+00	0.8109	BS	f	65	t
418	1	1448305237	3	18	2026-11-14 13:56:21.106881+00	0.899	BS	t	178	t
420	1	1448305237	3	15	2026-11-14 13:56:35.358355+00	0.2617	FT	f	246	t
433	1	1448305237	3	18	2026-11-14 13:58:01.097421+00	0.6596	BS	f	85	t
435	1	1448305237	3	19	2026-11-14 13:58:17.835563+00	0.0976	MW	f	189	t
437	1	1448305237	3	17	2026-11-14 13:58:29.055208+00	0.4682	BS	t	207	t
439	1	1448305237	3	19	2026-11-14 13:58:40.327342+00	0.5086	BS	t	173	t
441	1	8793965959	3	19	2026-11-14 13:59:57.042206+00	0.3383	FT	t	294	t
444	1	1448305237	3	20	2026-11-14 14:00:38.797893+00	0.1412	MW	t	313	t
449	1	1448305237	3	19	2026-11-14 14:01:14.334023+00	0.6677	BS	t	173	t
451	1	1448305237	3	19	2026-11-14 14:01:25.285974+00	0.8154	BS	t	173	t
453	1	1448305237	3	20	2026-11-14 14:01:37.293936+00	0.5841	BS	t	136	t
455	1	1448305237	3	17	2026-11-14 14:01:48.165272+00	0.4235	WW	t	270	t
468	1	1448305237	3	19	2026-11-14 14:03:00.239335+00	0.12	MW	t	398	t
470	1	1448305237	3	18	2026-11-14 14:03:11.255011+00	0.8161	BS	t	178	t
472	1	1448305237	3	18	2026-11-14 14:03:22.360493+00	0.3494	FT	t	303	t
488	1	1913085298	3	18	2026-11-14 14:33:17.169272+00	0.1192	MW	t	410	t
507	1	1913085298	3	17	2026-11-14 14:38:31.001918+00	0.8982	BS	t	207	t
522	1	1913085298	3	18	2026-11-14 14:44:04.263077+00	0.1544	FT	t	303	t
531	1	1913085298	3	15	2026-11-14 14:44:55.646922+00	0.9909	BS	t	304	t
560	1	1913085298	3	15	2026-11-14 14:47:38.680777+00	0.7114	BS	t	304	t
567	1	1913085298	3	16	2026-11-14 14:49:51.430993+00	0.3006	FT	f	224	t
569	1	1913085298	3	18	2026-11-14 14:50:02.505777+00	0.24	FT	t	303	t
571	1	1913085298	3	19	2026-11-14 14:50:13.670859+00	0.0208	FN	t	502	t
573	1	1913085298	3	16	2026-11-14 14:50:25.142951+00	0.6584	BS	f	132	t
575	1	1913085298	3	18	2026-11-14 14:50:36.532962+00	0.6027	BS	t	178	t
577	1	1913085298	3	16	2026-11-14 14:50:47.944849+00	0.9653	BS	t	277	t
588	1	1913085298	3	20	2026-11-14 14:51:54.21924+00	0.8761	BS	f	65	t
593	1	1913085298	3	15	2026-11-14 14:52:22.499538+00	0.1274	MW	f	333	t
595	1	1913085298	3	18	2026-11-14 14:52:33.811976+00	0.257	FT	f	144	t
401	1	1448305237	3	19	2026-11-14 13:54:45.061439+00	0.5036	BS	t	173	t
404	1	1448305237	3	21	2026-11-14 13:55:01.3946+00	0.0658	FN	t	365	t
413	1	1448305237	3	19	2026-11-14 13:55:51.319614+00	0.0121	FN	f	239	t
415	1	1448305237	3	18	2026-11-14 13:56:02.199981+00	0.0675	FN	t	517	t
417	1	1448305237	3	20	2026-11-14 13:56:13.239092+00	0.3171	FT	f	110	t
419	1	1448305237	3	21	2026-11-14 13:56:26.977562+00	0.8195	BS	t	126	t
421	1	1448305237	3	20	2026-11-14 13:56:44.166033+00	0.1112	MW	t	313	t
432	1	1448305237	3	18	2026-11-14 13:57:53.17098+00	0.9364	BS	t	178	t
434	1	1448305237	3	18	2026-11-14 13:58:12.401604+00	0.4308	WW	f	110	t
436	1	1448305237	3	14	2026-11-14 13:58:23.434378+00	0.6556	BS	t	504	t
438	1	1448305237	3	18	2026-11-14 13:58:34.675897+00	0.0981	MW	f	195	t
446	1	1448305237	3	20	2026-11-14 14:00:49.93327+00	0.7307	BS	t	136	t
456	1	1448305237	3	19	2026-11-14 14:01:53.572661+00	0.9302	BS	f	82	t
458	1	1448305237	3	18	2026-11-14 14:02:04.777703+00	0.2616	FT	f	144	t
460	1	1448305237	3	16	2026-11-14 14:02:15.933657+00	0.8089	BS	t	277	t
462	1	1448305237	3	17	2026-11-14 14:02:26.994355+00	0.3615	FT	f	168	t
464	1	1448305237	3	20	2026-11-14 14:02:38.221679+00	0.268	FT	f	110	t
466	1	1448305237	3	19	2026-11-14 14:02:49.167942+00	0.7656	BS	f	82	t
482	1	1913085298	3	13	2026-11-14 14:32:36.099795+00	0.6442	BS	f	600	t
496	1	1913085298	3	18	2026-11-14 14:37:19.567157+00	0.1675	FT	t	303	t
534	1	1913085298	3	21	2026-11-14 14:45:12.627367+00	0.1845	FT	t	214	t
536	1	1913085298	3	10	2026-11-14 14:45:24.125084+00	0.4549	BS	t	682	t
540	1	1913085298	3	16	2026-11-14 14:45:46.482236+00	0.4829	BS	t	277	t
557	1	1913085298	3	14	2026-11-14 14:47:21.87028+00	0.7537	BS	t	504	t
561	1	1913085298	3	19	2026-11-14 14:47:44.312761+00	0.2088	FT	t	294	t
566	1	1913085298	3	19	2026-11-14 14:49:45.351768+00	0.2329	FT	t	294	t
579	1	1913085298	3	15	2026-11-14 14:51:01.522019+00	0.9009	BS	f	145	t
581	1	1913085298	3	18	2026-11-14 14:51:14.649046+00	0.3863	WW	f	110	t
583	1	1913085298	3	18	2026-11-14 14:51:26.379728+00	0.8024	BS	t	178	t
585	1	1913085298	3	20	2026-11-14 14:51:37.493198+00	0.5607	BS	t	136	t
622	1	1913085298	3	20	2026-11-14 14:55:08.950228+00	0.2564	FT	f	110	t
625	1	1913085298	3	21	2026-11-14 14:55:27.334151+00	0.5129	BS	f	60	t
630	1	1913085298	3	21	2026-11-14 14:57:26.997775+00	0.9494	BS	t	126	t
637	1	1913085298	3	18	2026-11-14 14:59:18.709422+00	0.046	FN	t	517	t
639	1	1913085298	3	21	2026-11-14 14:59:31.912264+00	0.0551	FN	t	365	t
644	1	1913085298	3	15	2026-11-14 15:01:10.906439+00	0.0441	FN	t	883	t
648	1	1913085298	3	17	2026-11-14 15:01:35.689725+00	0.1266	MW	f	227	t
650	1	1913085298	3	9	2026-11-14 15:01:47.292171+00	0.7386	BS	t	840	t
659	1	1448305237	4	22	2026-11-14 15:05:17.107068+00	0.1695	FT	t	52993	t
664	1	1913085298	4	22	2026-11-14 15:05:55.677453+00	0.6573	BS	f	14844	t
665	1	1913085298	4	22	2026-11-14 15:06:01.184833+00	0.3204	FT	t	52993	t
677	1	1448305237	4	22	2026-11-14 15:06:54.741552+00	0.5283	BS	f	14844	t
678	1	1913085298	4	22	2026-11-14 15:07:06.387066+00	0.1398	MW	t	71696	t
681	1	1913085298	4	22	2026-11-14 15:07:30.519842+00	0.7766	BS	t	31172	t
685	1	1913085298	4	22	2026-11-14 15:09:10.773541+00	0.2769	FT	t	52993	t
689	1	1913085298	4	22	2026-11-14 15:11:16.542242+00	0.2218	FT	t	52993	t
691	1	1913085298	4	22	2026-11-14 15:11:28.706052+00	0.2043	FT	t	52993	t
693	1	1913085298	4	22	2026-11-14 15:26:17.664832+00	0.1369	MW	t	71696	t
696	1	1913085298	4	22	2026-11-14 15:26:34.523697+00	0.5756	BS	f	14844	t
698	1	1913085298	4	22	2026-11-14 15:26:46.101668+00	0.9749	BS	f	14844	t
702	1	1913085298	4	22	2026-11-14 15:29:43.554962+00	0.7509	BS	f	14844	t
703	1	1913085298	4	22	2026-11-14 15:29:49.12518+00	0.9203	BS	t	31172	t
704	1	1913085298	4	22	2026-11-14 15:29:54.787955+00	0.0324	FN	f	43047	t
705	1	1913085298	4	22	2026-11-14 15:31:38.802566+00	0.4683	BS	t	31172	t
706	1	1913085298	4	22	2026-11-14 15:32:56.327213+00	0.7128	BS	t	31172	t
707	1	1448305237	4	22	2026-11-14 15:39:27.905087+00	0.4109	WW	t	40524	t
708	1	1448305237	4	22	2026-11-14 15:39:34.30222+00	0.3125	FT	f	25234	t
709	1	1448305237	4	22	2026-11-14 15:39:40.346477+00	0.3784	FT	f	25234	t
710	1	1448305237	4	22	2026-11-14 15:39:46.727149+00	0.7394	BS	f	14844	t
711	1	1448305237	4	22	2026-11-14 15:39:53.244579+00	0.9423	BS	t	31172	t
712	1	1448305237	4	22	2026-11-14 15:39:59.291874+00	0.3756	FT	t	52993	t
713	1	1448305237	4	22	2026-11-14 15:40:05.384085+00	0.4885	BS	f	14844	t
714	1	1448305237	4	22	2026-11-14 15:40:26.936305+00	0.2853	FT	t	52993	t
715	1	1448305237	4	22	2026-11-14 15:40:33.498862+00	0.8119	BS	f	14844	t
716	1	1448305237	4	22	2026-11-14 15:40:39.456869+00	0.1021	MW	t	71696	t
717	1	1448305237	4	22	2026-11-14 15:40:45.372809+00	0.7312	BS	f	14844	t
718	1	1448305237	4	22	2026-11-14 15:40:51.780064+00	0.0609	FN	f	43047	t
719	1	1448305237	4	22	2026-11-14 15:40:58.88821+00	0.9079	BS	f	14844	t
720	1	1448305237	4	22	2026-11-14 15:41:06.95482+00	0.4561	BS	f	14844	t
721	1	1448305237	4	22	2026-11-14 15:41:12.847244+00	0.6387	BS	f	14844	t
722	1	1448305237	4	22	2026-11-14 15:41:18.877827+00	0.9283	BS	f	14844	t
723	1	1448305237	4	22	2026-11-14 15:41:24.760165+00	0.9153	BS	f	14844	t
724	1	1448305237	4	22	2026-11-14 15:41:31.396148+00	0.7907	BS	t	31172	t
725	1	1448305237	4	22	2026-11-14 15:44:59.30802+00	0.8264	BS	f	14844	t
726	1	1448305237	3	20	2026-11-14 15:47:01.527627+00	0.3038	FT	f	110	t
729	1	1448305237	4	24	2026-11-14 16:18:19.125491+00	0.0251	FN	t	13041	t
731	1	1448305237	4	27	2026-11-14 16:18:26.57134+00	0.4373	WW	f	2486	t
732	1	1448305237	4	23	2026-11-14 16:18:32.82792+00	0.9498	BS	f	10337	t
733	1	1448305237	4	24	2026-11-14 16:18:38.303321+00	0.6347	BS	t	4497	t
734	1	1448305237	4	28	2026-11-14 16:18:43.895489+00	0.1218	MW	f	4897	t
735	1	1448305237	4	23	2026-11-14 16:18:55.218026+00	0.2146	FT	t	36903	t
736	1	1913085298	4	27	2026-11-14 16:42:35.472534+00	0.0894	MW	t	9237	t
737	1	1913085298	4	27	2026-11-14 16:42:41.485897+00	0.9576	BS	t	4016	t
738	1	1913085298	4	28	2026-11-14 16:42:47.502232+00	0.506	BS	t	4471	t
739	1	1913085298	4	27	2026-11-14 16:42:54.080165+00	0.7871	BS	f	1912	t
740	1	1913085298	4	24	2026-11-14 16:42:59.932031+00	0.8467	BS	t	4497	t
741	1	1913085298	4	25	2026-11-14 16:43:05.564507+00	0.5697	BS	t	12954	t
742	1	1448305237	3	10	2026-11-14 16:43:09.653972+00	0.7399	BS	t	682	t
743	1	1448305237	3	20	2026-11-14 16:43:26.584355+00	0.5124	BS	f	65	t
744	1	1448305237	3	18	2026-11-14 16:43:35.678871+00	0.7804	BS	f	85	t
745	1	1448305237	3	15	2026-11-14 16:43:41.414257+00	0.1103	MW	t	700	t
746	1	1448305237	3	17	2026-11-14 16:43:48.25683+00	0.3524	FT	f	168	t
747	1	1448305237	3	20	2026-11-14 16:43:57.147367+00	0.6032	BS	f	65	t
748	1	1448305237	3	15	2026-11-14 16:44:03.141957+00	0.2164	FT	t	517	t
749	1	1448305237	4	24	2026-11-14 16:59:48.592222+00	0.0749	MW	t	10343	t
750	1	1448305237	4	28	2026-11-14 16:59:54.742157+00	0.2932	FT	f	3620	t
751	1	1448305237	4	30	2026-11-14 17:00:00.305404+00	0.7509	BS	f	2622	t
752	1	1448305237	4	26	2026-11-14 17:00:05.868995+00	0.7757	BS	t	6895	t
753	1	1448305237	4	26	2026-11-14 17:00:11.787855+00	0.1737	FT	f	5581	t
754	1	1448305237	4	23	2026-11-14 17:00:17.676331+00	0.6185	BS	f	10337	t
755	1	1448305237	4	31	2026-11-14 17:00:23.427162+00	0.2648	FT	f	4196	t
756	1	1448305237	4	23	2026-11-14 17:00:29.045494+00	0.2458	FT	f	17572	t
763	1	1448305237	4	23	2026-11-14 17:01:08.429388+00	0.5851	BS	t	21707	t
765	1	1448305237	4	22	2026-11-14 17:01:19.674427+00	0.9377	BS	f	14844	t
767	1	1448305237	4	27	2026-11-14 17:01:30.964977+00	0.7139	BS	t	4016	t
769	1	1448305237	4	26	2026-11-14 17:01:42.419922+00	0.0681	FN	f	9522	t
782	1	1448305237	4	24	2026-11-14 17:02:58.412659+00	0.9405	BS	t	4497	t
786	1	1448305237	4	27	2026-11-14 17:03:20.282658+00	0.7751	BS	f	1912	t
787	1	1448305237	4	27	2026-11-14 19:22:43.931505+00	0.3807	WW	t	5221	t
789	1	1448305237	4	37	2026-11-14 19:22:55.229042+00	0.2284	FT	f	825	t
791	1	1448305237	4	23	2026-11-14 19:23:06.394066+00	0.0854	MW	f	23775	t
794	1	1448305237	4	36	2026-11-14 19:23:22.911037+00	0.0678	FN	t	7472	t
796	1	1448305237	4	30	2026-11-14 19:23:34.512043+00	0.0753	MW	t	12664	t
798	1	1448305237	4	27	2026-11-14 19:23:52.942533+00	0.1562	FT	t	6827	t
799	1	1448305237	4	23	2026-11-14 19:24:14.57136+00	0.4473	WW	t	28220	t
800	1	1448305237	4	28	2026-11-14 19:24:20.361044+00	0.1182	MW	t	10285	t
801	1	1448305237	4	35	2026-11-14 19:24:26.03191+00	0.8544	BS	t	1181	t
802	1	1448305237	4	43	2026-11-14 19:24:31.92883+00	0.9989	BS	f	86	t
803	1	1629242254	4	24	2026-11-14 23:04:34.216054+00	0.4479	WW	t	5846	t
804	1	1629242254	4	23	2026-11-14 23:04:40.262368+00	0.7555	BS	f	10337	t
805	1	1629242254	4	25	2026-11-14 23:04:45.856003+00	0.3493	FT	f	10487	t
806	1	1629242254	4	36	2026-11-14 23:04:51.356089+00	0.1677	FT	t	4380	t
807	1	1629242254	4	41	2026-11-14 23:04:56.966027+00	0.2794	FT	t	465	t
808	1	1629242254	4	38	2026-11-14 23:05:02.316991+00	0.34	FT	t	11520	t
809	1	1629242254	4	35	2026-11-14 23:05:07.784576+00	0.1119	MW	f	1293	t
810	1	1629242254	4	28	2026-11-14 23:05:13.197559+00	0.5732	BS	f	2129	t
811	1	1629242254	4	42	2026-11-14 23:05:18.755101+00	0.3578	FT	f	546	t
812	1	1629242254	4	27	2026-11-14 23:05:23.855213+00	0.3767	FT	f	3251	t
813	1	1629242254	4	38	2026-11-14 23:05:29.246204+00	0.2505	FT	t	11520	t
814	1	1629242254	4	42	2026-11-14 23:05:34.679757+00	0.4833	BS	t	675	t
815	1	1629242254	4	36	2026-11-14 23:05:40.961837+00	0.7161	BS	f	1227	t
816	1	1629242254	4	41	2026-11-14 23:05:47.286518+00	0.0641	FN	f	378	t
817	1	1629242254	4	34	2026-11-14 23:05:53.429499+00	0.4964	BS	f	3309	t
818	1	1629242254	4	41	2026-11-14 23:05:58.785202+00	0.0948	MW	f	300	t
819	1	1629242254	4	24	2026-11-14 23:06:04.296843+00	0.7742	BS	t	4497	t
820	1	1629242254	4	28	2026-11-14 23:06:09.625836+00	0.084	MW	t	10285	t
821	1	1629242254	4	24	2026-11-14 23:06:14.913058+00	0.6218	BS	t	4497	t
822	1	1629242254	4	29	2026-11-14 23:06:20.292949+00	0.182	FT	f	1752	t
837	1	1448305237	4	44	2026-11-15 04:42:38.922379+00	0.6538	BS	t	153	t
843	1	1448305237	4	42	2026-11-15 04:49:37.41392+00	0.1771	FT	f	117	t
844	1	1448305237	4	38	2026-11-15 04:49:43.23817+00	0.2461	FT	f	253	t
845	1	1448305237	4	43	2026-11-15 04:49:49.642657+00	0.7183	BS	f	22	t
846	1	1448305237	4	37	2026-11-15 04:49:55.402193+00	0.4601	BS	t	203	t
847	1	1448305237	4	29	2026-11-15 04:50:01.370032+00	0.9926	BS	f	170	t
848	1	1448305237	4	43	2026-11-15 04:50:07.330233+00	0.9671	BS	f	22	t
849	1	1448305237	4	40	2026-11-15 04:50:12.765156+00	0.5482	BS	t	141	t
850	1	1448305237	4	32	2026-11-15 04:50:18.30003+00	0.3533	FT	f	527	t
851	1	1448305237	4	33	2026-11-15 04:50:25.405191+00	0.3022	FT	f	297	t
852	1	1448305237	4	42	2026-11-15 04:50:31.455377+00	0.5211	BS	t	144	t
853	1	1448305237	4	29	2026-11-15 04:50:37.069525+00	0.652	BS	t	357	t
854	1	1448305237	4	26	2026-11-15 04:50:42.72767+00	0.6627	BS	f	1175	t
855	1	1448305237	4	30	2026-11-15 04:50:48.37101+00	0.5828	BS	f	235	t
856	1	1448305237	4	39	2026-11-15 04:50:53.947292+00	0.3016	FT	f	991	t
857	1	1448305237	4	39	2026-11-15 04:50:59.908312+00	0.4594	BS	t	1225	t
858	1	1448305237	4	32	2026-11-15 04:51:05.880547+00	0.2426	FT	f	527	t
859	1	1448305237	4	32	2026-11-15 04:51:12.163642+00	0.0113	FN	f	899	t
860	1	1448305237	4	33	2026-11-15 04:52:06.373702+00	0.141	MW	t	845	t
861	1	1448305237	4	47	2026-11-15 04:52:13.142762+00	0.9726	BS	f	12	t
862	1	1448305237	4	42	2026-11-15 04:52:18.874785+00	0.8429	BS	t	144	t
863	1	1448305237	4	31	2026-11-15 04:52:24.484986+00	0.0906	MW	f	517	t
\.


--
-- Data for Name: manual_rewards; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.manual_rewards (id, user_id, tournament_id, description, status, created_by, created_at, given_at) FROM stdin;
\.


--
-- Data for Name: point_transactions; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.point_transactions (id, season_id, user_id, amount, source, meta, created_at) FROM stdin;
1	1	965425988	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-11 11:18:50.921282+00
2	1	965425988	-120	case_open	{"case_id": 1, "item_id": 2, "item_name": "Синий клинок"}	2026-11-11 11:18:57.478681+00
3	1	965425988	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 11:19:13.421134+00
4	1	965425988	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 11:27:02.20038+00
5	1	965425988	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 11:27:10.898371+00
6	1	965425988	5000	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-11 12:05:54.851535+00
7	1	965425988	5000	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-11 12:05:54.853352+00
8	1	965425988	5000	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-11 12:05:54.854175+00
9	1	965425988	5000	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-11 12:06:13.727435+00
10	1	965425988	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 12:06:23.251104+00
11	1	965425988	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 12:06:30.819443+00
12	1	965425988	-300	case_open	{"case_id": 2, "item_id": 6, "item_name": "Серебряный кубок"}	2026-11-11 12:06:36.170279+00
13	1	965425988	-300	case_open	{"case_id": 2, "item_id": 7, "item_name": "Платиновое кольцо"}	2026-11-11 12:06:42.49228+00
14	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:31:31.15227+00
15	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:31:41.030042+00
16	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:32:00.21961+00
17	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:32:09.834357+00
18	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:32:15.809002+00
19	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 12:32:24.242493+00
20	1	965425988	-120	case_open	{"case_id": 1, "item_id": 2, "item_name": "Синий клинок"}	2026-11-11 12:35:25.627493+00
21	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 12:58:52.670454+00
22	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:58:58.86742+00
23	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:59:04.831682+00
24	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:59:12.592603+00
25	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:59:18.272611+00
26	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 12:59:23.806918+00
27	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 13:07:12.975873+00
28	1	965425988	-10	case_open	{"case_id": 3, "item_id": 11, "item_name": "Che"}	2026-11-11 13:07:19.036356+00
29	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 13:09:13.439562+00
30	1	965425988	-10	case_open	{"case_id": 3, "item_id": 12, "item_name": "Trash"}	2026-11-11 13:09:20.165443+00
31	1	965425988	-10	case_open	{"case_id": 3, "item_id": 11, "item_name": "Che"}	2026-11-11 13:09:25.745464+00
32	1	965425988	-10	case_open	{"case_id": 3, "item_id": 12, "item_name": "Trash"}	2026-11-11 13:11:03.680622+00
33	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 18:35:43.858997+00
34	1	965425988	-300	case_open	{"case_id": 2, "item_id": 6, "item_name": "Серебряный кубок"}	2026-11-11 18:59:13.225653+00
35	1	965425988	-300	case_open	{"case_id": 2, "item_id": 6, "item_name": "Серебряный кубок"}	2026-11-11 18:59:19.106133+00
36	1	965425988	-300	case_open	{"case_id": 2, "item_id": 5, "item_name": "Медный диск"}	2026-11-11 18:59:24.760016+00
37	1	965425988	-300	case_open	{"case_id": 2, "item_id": 5, "item_name": "Медный диск"}	2026-11-11 18:59:30.474302+00
38	1	965425988	-300	case_open	{"case_id": 2, "item_id": 8, "item_name": "Корона"}	2026-11-11 19:01:52.591539+00
39	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 19:02:40.838462+00
40	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 19:04:45.099655+00
41	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 19:06:54.587631+00
42	1	965425988	-300	case_open	{"case_id": 2, "item_id": 6, "item_name": "Серебряный кубок"}	2026-11-11 19:07:20.064176+00
43	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 19:32:37.509073+00
44	1	965425988	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 19:32:43.305984+00
45	1	965425988	-300	case_open	{"case_id": 2, "item_id": 5, "item_name": "Медный диск"}	2026-11-11 19:32:49.098798+00
46	1	965425988	-300	case_open	{"case_id": 2, "item_id": 5, "item_name": "Медный диск"}	2026-11-11 19:32:55.493179+00
47	1	483243639	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 19:35:58.080536+00
48	1	483243639	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 19:36:05.06966+00
49	1	483243639	-120	case_open	{"case_id": 1, "item_id": 2, "item_name": "Синий клинок"}	2026-11-11 19:36:13.708655+00
106	1	965425988	50	tournament	{"rank": 2, "tournament_id": 23}	2026-11-12 12:17:17.217001+00
50	1	483243639	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 19:36:22.156396+00
1245	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 33, "item_name": "Жгучая Ярость"}	2026-11-15 04:52:06.373702+00
1250	1	1448305237	-249	case_open	{"case_id": 5, "item_id": 53, "item_name": "Электрический Улей"}	2026-11-15 05:46:33.109808+00
1259	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 60, "item_name": "Мортис"}	2026-11-15 06:19:30.482817+00
51	1	483243639	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 19:36:28.135558+00
52	1	483243639	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 19:36:36.696638+00
53	1	965425988	-120	case_open	{"case_id": 1, "item_id": 2, "item_name": "Синий клинок"}	2026-11-11 19:36:53.429183+00
54	1	483243639	100	tournament	{"rank": 1, "tournament_id": 3}	2026-11-11 19:44:06.211362+00
55	1	965425988	50	tournament	{"rank": 2, "tournament_id": 3}	2026-11-11 19:44:06.211362+00
56	1	965425988	100	tournament	{"rank": 1, "tournament_id": 2}	2026-11-11 20:05:06.223253+00
57	1	483243639	50	tournament	{"rank": 2, "tournament_id": 2}	2026-11-11 20:05:06.223253+00
58	1	483243639	100	tournament	{"rank": 1, "tournament_id": 4}	2026-11-11 20:23:06.20896+00
59	1	965425988	50	tournament	{"rank": 2, "tournament_id": 4}	2026-11-11 20:23:06.20896+00
60	1	965425988	-300	case_open	{"case_id": 2, "item_id": 6, "item_name": "Серебряный кубок"}	2026-11-11 20:38:07.973318+00
61	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 20:43:07.879175+00
62	1	965425988	100	tournament	{"rank": 1, "tournament_id": 5}	2026-11-11 20:46:04.819475+00
63	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 21:06:25.503264+00
64	1	965425988	-300	case_open	{"case_id": 2, "item_id": 6, "item_name": "Серебряный кубок"}	2026-11-11 21:06:32.736427+00
65	1	965425988	100	tournament	{"rank": 1, "tournament_id": 6}	2026-11-11 21:39:37.836537+00
66	1	965425988	100	tournament	{"rank": 1, "tournament_id": 7}	2026-11-11 21:40:37.847195+00
67	1	965425988	100	tournament	{"rank": 1, "tournament_id": 8}	2026-11-11 21:47:37.844251+00
68	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 22:00:09.52673+00
69	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 22:00:15.897154+00
70	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 22:00:22.397468+00
71	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 22:00:29.244015+00
72	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 22:00:35.016297+00
73	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 22:04:02.540899+00
74	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 22:04:41.90848+00
75	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 22:04:51.582531+00
76	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 22:04:57.426906+00
77	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 22:14:01.760636+00
78	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-11 22:14:13.339397+00
79	1	483243639	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 22:25:44.929804+00
80	1	483243639	-120	case_open	{"case_id": 1, "item_id": 1, "item_name": "Серый болт"}	2026-11-11 22:25:52.392595+00
81	1	483243639	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-11 22:25:58.577124+00
82	1	965425988	100	tournament	{"rank": 1, "tournament_id": 9}	2026-11-11 22:50:25.513255+00
83	1	483243639	50	tournament	{"rank": 2, "tournament_id": 9}	2026-11-11 22:50:25.513255+00
84	1	965425988	100	tournament	{"rank": 1, "tournament_id": 10}	2026-11-11 22:52:25.510335+00
85	1	483243639	50	tournament	{"rank": 2, "tournament_id": 10}	2026-11-11 22:52:25.510335+00
86	1	483243639	30	subscription	{}	2026-11-11 23:44:17.734498+00
87	1	965425988	30	subscription	{}	2026-11-11 23:45:18.520979+00
88	1	8800648129	30	subscription	{}	2026-11-12 08:16:07.777033+00
89	1	965425988	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-12 09:48:41.121569+00
90	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-12 09:52:22.500636+00
91	1	8800648129	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-12 10:10:03.200345+00
92	1	965425988	100	tournament	{"rank": 1, "tournament_id": 21}	2026-11-12 10:14:13.761992+00
93	1	8800648129	50	tournament	{"rank": 2, "tournament_id": 21}	2026-11-12 10:14:13.761992+00
94	1	8800648129	2	comment	{"len": 16}	2026-11-12 10:17:42.237787+00
95	1	8800648129	2	comment	{"len": 16}	2026-11-12 10:20:23.525479+00
96	1	8800648129	2	comment	{"len": 16}	2026-11-12 10:21:14.275083+00
97	1	8800648129	-10	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 защитная сетка"}	2026-11-12 10:21:32.843757+00
98	1	8800648129	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-12 10:21:39.041769+00
99	1	8800648129	1000	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-12 10:48:58.703084+00
100	1	8800648129	10	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-12 10:49:08.159609+00
101	1	8800648129	1000	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-12 11:41:21.925926+00
102	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-12 11:49:28.507264+00
103	1	8800648129	1000	manual	{"reason": "addpoints command", "admin_id": 965425988}	2026-11-12 11:51:31.833997+00
104	1	8800648129	-300	case_open	{"case_id": 2, "item_id": 5, "item_name": "Медный диск"}	2026-11-12 11:52:12.688859+00
105	1	8800648129	100	tournament	{"rank": 1, "tournament_id": 23}	2026-11-12 12:17:17.217001+00
107	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-12 13:27:24.889679+00
108	1	965425988	-10	case_open	{"case_id": 3, "item_id": 10, "item_name": "Clock-18 ночь"}	2026-11-12 13:28:12.118457+00
109	1	965425988	100	tournament	{"rank": 1, "tournament_id": 25}	2026-11-12 14:21:03.238347+00
110	1	965425988	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-12 15:09:22.367311+00
111	1	965425988	100	tournament	{"rank": 1, "tournament_id": 26}	2026-11-12 15:22:56.756567+00
112	1	8800648129	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 15:30:10.734641+00
113	1	8800648129	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 15:30:16.780617+00
114	1	8800648129	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 15:30:22.069682+00
115	1	8800648129	-50	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 Пустынный повстанец"}	2026-11-12 15:30:27.721478+00
116	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-12 15:45:28.026854+00
117	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 15:45:36.876687+00
118	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 15:45:47.402731+00
119	1	1629242254	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-12 15:48:28.919904+00
120	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 15:48:37.759177+00
121	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 15:48:43.763282+00
122	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 15:48:49.430423+00
123	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 15:48:55.108429+00
124	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 15:49:00.634341+00
125	1	1629242254	500	subscription	{}	2026-11-12 15:56:55.492368+00
126	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-12 16:03:25.688775+00
127	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-12 16:03:45.29617+00
128	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 16:03:56.743121+00
129	1	1448305237	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-12 16:04:13.278235+00
130	1	233835983	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-12 16:05:23.225791+00
131	1	233835983	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-12 16:05:26.888589+00
132	1	233835983	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 16:05:36.281662+00
133	1	233835983	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 16:05:43.782145+00
134	1	233835983	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 16:05:49.729774+00
135	1	233835983	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-12 16:05:56.59735+00
136	1	8793965959	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-12 16:05:57.791419+00
137	1	8793965959	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 16:07:03.814435+00
138	1	8793965959	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 16:07:10.667325+00
139	1	8793965959	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 16:07:16.250956+00
140	1	8793965959	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-12 16:07:21.592885+00
141	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 16:17:26.515629+00
142	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 16:17:37.663231+00
143	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 16:19:02.359788+00
144	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:27:53.500033+00
145	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:28:04.72057+00
146	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 18:28:12.540582+00
147	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:28:20.973014+00
148	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:28:30.355549+00
149	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 18:28:37.03905+00
150	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:28:43.006543+00
151	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:28:54.038341+00
152	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 13, "item_name": "AWP Азимов"}	2026-11-12 18:28:59.653233+00
153	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-12 18:29:08.180981+00
154	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:31:44.686754+00
155	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:31:51.283876+00
156	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 18:31:56.720181+00
161	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:32:24.528167+00
171	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 18:52:49.772935+00
1246	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 47, "item_name": "Смешанный Серый"}	2026-11-15 04:52:13.142762+00
1258	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 60, "item_name": "Мортис"}	2026-11-15 06:19:24.653676+00
157	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 18:32:02.296637+00
162	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-12 18:32:29.982447+00
166	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-12 18:52:21.972417+00
1247	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 42, "item_name": "Элитное Снаряжение"}	2026-11-15 04:52:18.874785+00
1251	1	1448305237	-249	case_open	{"case_id": 5, "item_id": 72, "item_name": "Разлив Мышьяка"}	2026-11-15 05:51:50.295331+00
1253	1	1448305237	-249	case_open	{"case_id": 5, "item_id": 67, "item_name": "Бог Червей"}	2026-11-15 05:52:02.271786+00
1256	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 66, "item_name": "Экзоскелет"}	2026-11-15 06:19:13.182775+00
158	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:32:07.92525+00
163	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 18:32:35.551669+00
165	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:52:15.231617+00
1248	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 31, "item_name": "Фантомный Вредитель"}	2026-11-15 04:52:24.484986+00
1252	1	1448305237	-249	case_open	{"case_id": 5, "item_id": 54, "item_name": "Кортисейра"}	2026-11-15 05:51:56.022908+00
1254	1	1448305237	-249	case_open	{"case_id": 5, "item_id": 63, "item_name": "Древесная Гадюка"}	2026-11-15 05:52:07.874902+00
1257	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 62, "item_name": "Фобос"}	2026-11-15 06:19:19.144643+00
159	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-12 18:32:13.39064+00
164	1	1913085298	1000	manual	{"reason": "addpoints command", "admin_id": 1629242254}	2026-11-12 18:49:25.263779+00
167	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:52:27.822326+00
169	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 18:52:38.606125+00
1249	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 42, "item_name": "Элитное Снаряжение"}	2026-11-15 04:52:30.418121+00
1255	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 59, "item_name": "Двойственность"}	2026-11-15 06:19:06.692478+00
160	1	7756709710	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-12 18:32:18.928682+00
168	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:52:33.152615+00
170	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:52:44.108448+00
172	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:52:55.194231+00
173	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-12 18:53:02.063358+00
174	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 18:53:09.053289+00
175	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:53:14.655461+00
176	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:53:20.053818+00
177	1	233835983	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 18:57:48.571735+00
178	1	233835983	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-12 18:57:54.423083+00
179	1	233835983	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 18:58:00.388086+00
180	1	233835983	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-12 18:58:07.469921+00
181	1	233835983	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-12 18:58:12.626696+00
182	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-12 18:59:46.917703+00
183	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 18:59:53.030336+00
184	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 18:59:59.273697+00
185	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-12 19:00:05.580459+00
186	1	1629242254	500	manual	{"reason": "addpoints command", "admin_id": 1629242254}	2026-11-12 19:46:20.847142+00
187	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 19:46:56.137604+00
188	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 19:47:01.641715+00
189	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 19:47:06.969441+00
190	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-12 19:47:12.175709+00
191	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 19:47:17.482757+00
192	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 20:34:21.756247+00
193	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 20:34:27.122733+00
194	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 20:34:32.51834+00
195	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 20:34:38.312208+00
196	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 20:34:43.557151+00
197	1	1629242254	500	manual	{"reason": "addpoints command", "admin_id": 1629242254}	2026-11-12 23:09:19.471052+00
198	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 23:09:36.831865+00
199	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-12 23:09:42.322573+00
200	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-12 23:09:47.598064+00
201	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 23:09:53.866482+00
202	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-12 23:09:59.593513+00
203	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-12 23:10:05.389389+00
204	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 23:10:13.939605+00
205	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-12 23:10:19.356507+00
206	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-12 23:10:25.463505+00
207	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-12 23:10:30.805796+00
208	1	1448305237	20	daily	{"base": 10, "bonus": 10, "streak": 2}	2026-11-13 07:57:57.293716+00
209	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-13 10:51:01.324254+00
210	1	1913085298	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-13 14:29:18.527289+00
211	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-13 14:29:37.769536+00
212	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-13 14:29:45.646407+00
213	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-13 14:29:54.684234+00
214	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 14:30:00.550264+00
215	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-13 14:30:06.385896+00
216	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-13 14:30:12.082266+00
217	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-13 14:30:17.978563+00
224	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-13 14:31:00.913515+00
229	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 14:31:30.72853+00
230	1	5714687590	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-13 16:20:43.375336+00
232	1	5714687590	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-13 16:21:04.367241+00
1260	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 32, "item_name": "Нуво Руж"}	2026-11-15 13:47:43.821899+00
1286	1	965425988	-129	case_open	{"case_id": 9, "item_id": 163, "item_name": "Тропический Бриз"}	2026-11-16 20:05:54.050971+00
218	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 14:30:23.768039+00
225	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-13 14:31:06.793994+00
231	1	1629242254	20	daily	{"base": 10, "bonus": 10, "streak": 2}	2026-11-13 16:20:54.302727+00
1261	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 47, "item_name": "Смешанный Серый"}	2026-11-15 13:47:49.40588+00
1287	1	1448305237	20	daily	{"base": 10, "bonus": 10, "streak": 2}	2026-11-17 07:56:36.581703+00
1307	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 162, "item_name": "Горный Камуфляж"}	2026-11-17 07:57:25.008937+00
1309	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 167, "item_name": "Едва Зелёный"}	2026-11-17 07:57:37.158791+00
1311	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 168, "item_name": "Пустынная Тактика"}	2026-11-17 07:57:52.697402+00
1313	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 158, "item_name": "Черный Лотос"}	2026-11-17 07:58:04.329201+00
1315	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 160, "item_name": "Бесшумный Выстрел"}	2026-11-17 07:58:15.579995+00
1316	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 72, "item_name": "Разлив Мышьяка"}	2026-11-17 07:58:45.316175+00
1318	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 63, "item_name": "Древесная Гадюка"}	2026-11-17 07:58:56.770328+00
1320	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 52, "item_name": "Хроматическая Аберрация"}	2026-11-17 07:59:08.281116+00
1322	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 71, "item_name": "Капилляры"}	2026-11-17 07:59:20.653654+00
219	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-13 14:30:29.714168+00
221	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-13 14:30:41.865492+00
226	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-13 14:31:13.645537+00
234	1	5714687590	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-13 16:21:27.528164+00
1262	1	1448305237	500	tournament	{"rank": 1, "tournament_id": 28}	2026-11-15 15:11:25.390351+00
1263	1	1913085298	400	tournament	{"rank": 2, "tournament_id": 28}	2026-11-15 15:11:25.390351+00
1264	1	1629242254	300	tournament	{"rank": 3, "tournament_id": 28}	2026-11-15 15:11:25.390351+00
1267	1	1448305237	-199	case_open	{"case_id": 7, "item_id": 121, "item_name": "Мейнфрейм"}	2026-11-15 16:07:02.449427+00
1288	1	1448305237	22	sell_item	{"drop_id": 889}	2026-11-17 07:56:51.172373+00
1289	1	1448305237	22	sell_item	{"drop_id": 888}	2026-11-17 07:56:52.277343+00
1290	1	1448305237	36	sell_item	{"drop_id": 887}	2026-11-17 07:56:53.254249+00
1291	1	1448305237	61	sell_item	{"drop_id": 886}	2026-11-17 07:56:54.10762+00
1292	1	1448305237	29	sell_item	{"drop_id": 885}	2026-11-17 07:56:55.004022+00
1293	1	1448305237	24	sell_item	{"drop_id": 884}	2026-11-17 07:56:55.791285+00
1295	1	1448305237	204	sell_item	{"drop_id": 882}	2026-11-17 07:56:58.086788+00
1297	1	1448305237	89	sell_item	{"drop_id": 880}	2026-11-17 07:57:00.051517+00
1299	1	1448305237	351	sell_item	{"drop_id": 869}	2026-11-17 07:57:02.109072+00
1301	1	1448305237	1346	sell_item	{"drop_id": 867}	2026-11-17 07:57:03.697708+00
1303	1	1448305237	2755	sell_item	{"drop_id": 865}	2026-11-17 07:57:05.365632+00
1308	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 153, "item_name": "Королевский Страж"}	2026-11-17 07:57:31.038201+00
1310	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 150, "item_name": "Взгляд в Прошлое"}	2026-11-17 07:57:46.891408+00
1312	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 154, "item_name": "Билет в Ад"}	2026-11-17 07:57:58.444782+00
1314	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 153, "item_name": "Королевский Страж"}	2026-11-17 07:58:09.985902+00
220	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 14:30:35.653828+00
222	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-13 14:30:49.439894+00
227	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-13 14:31:19.289062+00
1265	1	1448305237	-199	case_open	{"case_id": 7, "item_id": 111, "item_name": "Мастер Травли"}	2026-11-15 16:06:50.438214+00
1294	1	1448305237	117	sell_item	{"drop_id": 883}	2026-11-17 07:56:56.786357+00
1296	1	1448305237	89	sell_item	{"drop_id": 881}	2026-11-17 07:56:59.206434+00
1298	1	1448305237	396	sell_item	{"drop_id": 870}	2026-11-17 07:57:00.980039+00
1300	1	1448305237	85	sell_item	{"drop_id": 868}	2026-11-17 07:57:02.903632+00
1302	1	1448305237	15	sell_item	{"drop_id": 866}	2026-11-17 07:57:04.523893+00
1304	1	1448305237	200	sell_item	{"drop_id": 864}	2026-11-17 07:57:06.158434+00
1306	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 153, "item_name": "Королевский Страж"}	2026-11-17 07:57:19.348361+00
1317	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 62, "item_name": "Фобос"}	2026-11-17 07:58:50.957692+00
1319	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 52, "item_name": "Хроматическая Аберрация"}	2026-11-17 07:59:02.453296+00
1321	1	1448305237	-350	case_open	{"case_id": 5, "item_id": 70, "item_name": "Ахерон"}	2026-11-17 07:59:14.957293+00
223	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 14:30:55.226948+00
228	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-13 14:31:24.87946+00
233	1	5714687590	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 16:21:11.201703+00
235	1	5714687590	500	subscription	{}	2026-11-13 21:25:31.673057+00
236	1	1629242254	100	tournament	{"rank": 1, "tournament_id": 27}	2026-11-13 22:31:21.069923+00
237	1	1913085298	50	tournament	{"rank": 2, "tournament_id": 27}	2026-11-13 22:31:21.069923+00
238	1	1629242254	100	tournament	{"rank": 1, "tournament_id": 30}	2026-11-13 22:35:05.272487+00
239	1	1913085298	50	tournament	{"rank": 2, "tournament_id": 30}	2026-11-13 22:35:05.272487+00
240	1	233835983	20	tournament	{"rank": 3, "tournament_id": 30}	2026-11-13 22:35:05.272487+00
241	1	1913085298	100	tournament	{"rank": 1, "tournament_id": 32}	2026-11-13 22:35:07.238074+00
242	1	5714687590	50	tournament	{"rank": 2, "tournament_id": 32}	2026-11-13 22:35:07.238074+00
243	1	965425988	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 22:39:53.384346+00
244	1	965425988	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-13 22:40:02.369614+00
245	1	965425988	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-13 22:40:18.517833+00
246	1	965425988	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 22:40:50.42439+00
247	1	965425988	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-13 22:41:03.658822+00
248	1	965425988	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-13 22:59:37.615449+00
249	1	965425988	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-13 22:59:48.016251+00
250	1	965425988	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-13 22:59:58.996762+00
251	1	965425988	132	sell_item	{"drop_id": 194}	2026-11-13 23:00:56.078917+00
252	1	965425988	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-13 23:01:03.478097+00
253	1	965425988	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-13 23:01:19.690586+00
254	1	965425988	277	sell_item	{"drop_id": 195}	2026-11-13 23:03:00.972261+00
255	1	1170057607	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-13 23:09:04.569308+00
256	1	1170057607	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-13 23:10:17.960393+00
257	1	1170057607	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-13 23:10:25.648132+00
258	1	1170057607	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-13 23:10:31.516602+00
259	1	1170057607	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-13 23:10:38.788826+00
260	1	1170057607	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-13 23:10:44.864907+00
261	1	1170057607	10	comment	{"len": 18}	2026-11-13 23:13:02.529713+00
262	1	965425988	250	referral	{"referred_id": 1170057607}	2026-11-13 23:13:02.529713+00
263	1	965425988	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-13 23:23:29.44925+00
264	1	1170057607	100	tournament	{"rank": 1, "tournament_id": 33}	2026-11-13 23:39:31.514735+00
265	1	965425988	50	tournament	{"rank": 2, "tournament_id": 33}	2026-11-13 23:39:31.514735+00
266	1	1913085298	100	tournament	{"rank": 1, "tournament_id": 31}	2026-11-14 00:01:01.679487+00
267	1	1170057607	50	tournament	{"rank": 2, "tournament_id": 31}	2026-11-14 00:01:01.679487+00
268	1	965425988	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 11:10:32.655293+00
269	1	965425988	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 11:10:38.244411+00
270	1	965425988	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 11:10:43.392136+00
271	1	965425988	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 11:11:31.280399+00
272	1	965425988	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 11:11:44.08843+00
273	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 11:29:22.759449+00
274	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 11:29:33.874708+00
275	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 11:29:39.84235+00
276	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 11:29:47.596591+00
277	1	965425988	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 11:31:26.84499+00
278	1	965425988	100	tournament	{"rank": 1, "tournament_id": 48}	2026-11-14 11:57:10.441305+00
279	1	1629242254	50	tournament	{"rank": 2, "tournament_id": 48}	2026-11-14 11:57:10.441305+00
280	1	965425988	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 12:29:40.670243+00
281	1	965425988	100	tournament	{"rank": 1, "tournament_id": 49}	2026-11-14 12:31:55.191665+00
282	1	965425988	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 12:33:56.653381+00
283	1	965425988	246	sell_item	{"drop_id": 213}	2026-11-14 12:35:27.406849+00
284	1	965425988	107	sell_item	{"drop_id": 212}	2026-11-14 12:35:28.048152+00
285	1	965425988	207	sell_item	{"drop_id": 211}	2026-11-14 12:35:28.607725+00
286	1	965425988	214	sell_item	{"drop_id": 206}	2026-11-14 12:35:29.121341+00
287	1	965425988	224	sell_item	{"drop_id": 205}	2026-11-14 12:35:29.676582+00
288	1	965425988	178	sell_item	{"drop_id": 204}	2026-11-14 12:35:30.141087+00
289	1	965425988	303	sell_item	{"drop_id": 203}	2026-11-14 12:35:30.627938+00
290	1	965425988	214	sell_item	{"drop_id": 202}	2026-11-14 12:35:31.042261+00
291	1	965425988	126	sell_item	{"drop_id": 201}	2026-11-14 12:35:31.449254+00
292	1	965425988	149	sell_item	{"drop_id": 193}	2026-11-14 12:35:31.854412+00
293	1	965425988	682	sell_item	{"drop_id": 192}	2026-11-14 12:35:32.299331+00
294	1	965425988	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 12:46:34.536122+00
295	1	965425988	240	sell_item	{"drop_id": 214}	2026-11-14 12:47:48.96037+00
296	1	965425988	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:07:37.473467+00
297	1	965425988	-50	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 Пустынный повстанец"}	2026-11-14 13:07:41.66818+00
298	1	965425988	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:07:55.246789+00
299	1	965425988	20	daily	{"base": 10, "bonus": 10, "streak": 2}	2026-11-14 13:08:03.850059+00
300	1	965425988	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:08:11.028502+00
301	1	965425988	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:20:05.878735+00
302	1	965425988	126	sell_item	{"drop_id": 219}	2026-11-14 13:20:24.268523+00
303	1	965425988	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:22:28.540051+00
304	1	965425988	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:22:33.95502+00
305	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:26:18.207162+00
306	1	1448305237	25	daily	{"base": 10, "bonus": 15, "streak": 3}	2026-11-14 13:28:36.671967+00
307	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 13:28:44.665486+00
308	1	1448305237	1160	sell_item	{"drop_id": 223}	2026-11-14 13:29:29.564637+00
309	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:29:38.496613+00
310	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:29:45.472882+00
311	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:29:51.557075+00
312	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:29:57.856001+00
313	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:30:04.104446+00
314	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 13, "item_name": "AWP Азимов"}	2026-11-14 13:30:10.078974+00
315	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:30:16.90263+00
316	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:30:23.019601+00
317	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:30:29.075023+00
318	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 13:30:35.995609+00
319	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:30:44.758575+00
320	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:30:51.615664+00
321	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:30:57.91364+00
322	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:31:04.174615+00
323	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:31:10.209738+00
324	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:31:17.477361+00
325	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:31:23.870679+00
326	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:31:29.633328+00
327	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:31:35.39188+00
328	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:31:41.127624+00
329	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:31:47.02084+00
330	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:31:52.791994+00
331	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:31:59.000581+00
332	1	1448305237	700	sell_item	{"drop_id": 246}	2026-11-14 13:32:16.592504+00
333	1	1448305237	136	sell_item	{"drop_id": 245}	2026-11-14 13:32:17.649625+00
334	1	1448305237	102	sell_item	{"drop_id": 244}	2026-11-14 13:32:18.570958+00
335	1	1448305237	132	sell_item	{"drop_id": 243}	2026-11-14 13:32:19.466213+00
336	1	1448305237	144	sell_item	{"drop_id": 242}	2026-11-14 13:32:20.286904+00
337	1	1448305237	178	sell_item	{"drop_id": 241}	2026-11-14 13:32:21.18691+00
338	1	1448305237	136	sell_item	{"drop_id": 240}	2026-11-14 13:32:22.048827+00
339	1	1448305237	145	sell_item	{"drop_id": 239}	2026-11-14 13:32:22.912687+00
340	1	1448305237	126	sell_item	{"drop_id": 238}	2026-11-14 13:32:23.749281+00
341	1	1448305237	303	sell_item	{"drop_id": 237}	2026-11-14 13:32:24.615293+00
346	1	1448305237	502	sell_item	{"drop_id": 232}	2026-11-14 13:32:28.776983+00
351	1	1448305237	188	sell_item	{"drop_id": 227}	2026-11-14 13:32:32.812971+00
355	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:33:59.127982+00
357	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 13:34:10.769332+00
359	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:34:23.503405+00
360	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:34:29.148869+00
363	1	1448305237	395	sell_item	{"drop_id": 254}	2026-11-14 13:36:54.938938+00
365	1	1448305237	132	sell_item	{"drop_id": 252}	2026-11-14 13:36:56.66934+00
367	1	1448305237	313	sell_item	{"drop_id": 250}	2026-11-14 13:36:58.247061+00
369	1	1448305237	163	sell_item	{"drop_id": 248}	2026-11-14 13:37:00.539717+00
373	1	965425988	100	tournament	{"rank": 1, "tournament_id": 50}	2026-11-14 13:37:50.034124+00
374	1	1448305237	50	tournament	{"rank": 2, "tournament_id": 50}	2026-11-14 13:37:50.034124+00
376	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:38:00.127983+00
378	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:38:15.020743+00
381	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:38:35.320894+00
383	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 13:38:47.99848+00
392	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:39:56.212737+00
394	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:40:07.180396+00
395	1	1448305237	136	sell_item	{"drop_id": 276}	2026-11-14 13:41:00.867472+00
397	1	1448305237	140	sell_item	{"drop_id": 274}	2026-11-14 13:41:02.533022+00
399	1	1448305237	132	sell_item	{"drop_id": 272}	2026-11-14 13:41:03.921576+00
401	1	1448305237	99	sell_item	{"drop_id": 270}	2026-11-14 13:41:05.380062+00
403	1	1448305237	65	sell_item	{"drop_id": 268}	2026-11-14 13:41:06.680006+00
405	1	1448305237	149	sell_item	{"drop_id": 266}	2026-11-14 13:41:08.044676+00
407	1	1448305237	140	sell_item	{"drop_id": 264}	2026-11-14 13:41:09.316149+00
409	1	1448305237	85	sell_item	{"drop_id": 262}	2026-11-14 13:41:10.679603+00
411	1	1448305237	82	sell_item	{"drop_id": 260}	2026-11-14 13:41:12.350666+00
413	1	1448305237	168	sell_item	{"drop_id": 258}	2026-11-14 13:41:13.813411+00
415	1	1448305237	294	sell_item	{"drop_id": 256}	2026-11-14 13:41:15.205129+00
1266	1	1448305237	-199	case_open	{"case_id": 7, "item_id": 110, "item_name": "Листовая Молния"}	2026-11-15 16:06:56.643212+00
1305	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 151, "item_name": "Страж"}	2026-11-17 07:57:13.494171+00
342	1	1448305237	178	sell_item	{"drop_id": 236}	2026-11-14 13:32:25.473517+00
345	1	1448305237	504	sell_item	{"drop_id": 233}	2026-11-14 13:32:28.016911+00
350	1	1448305237	60	sell_item	{"drop_id": 228}	2026-11-14 13:32:32.008604+00
352	1	1448305237	144	sell_item	{"drop_id": 226}	2026-11-14 13:32:33.549409+00
375	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:37:54.53198+00
377	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:38:08.555495+00
379	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:38:21.15427+00
380	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:38:29.592757+00
382	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:38:40.877721+00
391	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:39:50.630999+00
393	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:40:01.707415+00
396	1	1448305237	277	sell_item	{"drop_id": 275}	2026-11-14 13:41:01.771168+00
398	1	1448305237	60	sell_item	{"drop_id": 273}	2026-11-14 13:41:03.232261+00
400	1	1448305237	126	sell_item	{"drop_id": 271}	2026-11-14 13:41:04.640841+00
402	1	1448305237	188	sell_item	{"drop_id": 269}	2026-11-14 13:41:06.012932+00
404	1	1448305237	145	sell_item	{"drop_id": 267}	2026-11-14 13:41:07.33069+00
406	1	1448305237	504	sell_item	{"drop_id": 265}	2026-11-14 13:41:08.711188+00
408	1	1448305237	398	sell_item	{"drop_id": 263}	2026-11-14 13:41:10.03186+00
410	1	1448305237	277	sell_item	{"drop_id": 261}	2026-11-14 13:41:11.591318+00
412	1	1448305237	132	sell_item	{"drop_id": 259}	2026-11-14 13:41:13.084862+00
414	1	1448305237	398	sell_item	{"drop_id": 257}	2026-11-14 13:41:14.509255+00
416	1	1448305237	60	sell_item	{"drop_id": 255}	2026-11-14 13:41:15.993493+00
418	1	1629242254	25	daily	{"base": 10, "bonus": 15, "streak": 3}	2026-11-14 13:41:38.671883+00
1268	1	1448305237	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-16 08:32:12.062651+00
1323	1	965425988	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-17 09:59:12.89778+00
1326	1	965425988	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-17 09:59:35.398277+00
1328	1	965425988	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-17 09:59:55.708527+00
1331	1	965425988	82	sell_item	{"drop_id": 912}	2026-11-17 10:00:46.336718+00
1332	1	965425988	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-17 10:01:03.099644+00
1338	1	1448305237	-199	case_open	{"case_id": 7, "item_id": 114, "item_name": "Полимерный Рожок"}	2026-11-17 11:18:11.038653+00
1341	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 162, "item_name": "Горный Камуфляж"}	2026-11-17 11:18:39.097598+00
1342	1	1448305237	102	sell_item	{"drop_id": 916}	2026-11-17 11:18:45.709066+00
343	1	1448305237	82	sell_item	{"drop_id": 235}	2026-11-14 13:32:26.347884+00
348	1	1448305237	102	sell_item	{"drop_id": 230}	2026-11-14 13:32:30.388506+00
353	1	1448305237	207	sell_item	{"drop_id": 225}	2026-11-14 13:32:34.673227+00
361	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:34:34.884587+00
372	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:37:48.883706+00
384	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:38:54.928463+00
386	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:39:20.913014+00
388	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:39:32.634221+00
390	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:39:45.011226+00
1269	1	1448305237	14	sell_item	{"drop_id": 879}	2026-11-16 10:05:20.805103+00
1272	1	1448305237	282	sell_item	{"drop_id": 874}	2026-11-16 10:05:23.605085+00
1275	1	1448305237	529	sell_item	{"drop_id": 871}	2026-11-16 10:05:26.707526+00
1277	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 136, "item_name": "Метеорит"}	2026-11-16 10:05:47.935267+00
1280	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 139, "item_name": "Бронзовая Декорация"}	2026-11-16 10:06:05.207364+00
1283	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 133, "item_name": "Змеиный Выпад"}	2026-11-16 10:06:21.740445+00
1324	1	965425988	126	sell_item	{"drop_id": 909}	2026-11-17 09:59:19.304331+00
1329	1	965425988	360	sell_item	{"drop_id": 911}	2026-11-17 10:00:03.634062+00
1330	1	965425988	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-17 10:00:30.502955+00
1345	1	1629242254	-129	case_open	{"case_id": 9, "item_id": 168, "item_name": "Пустынная Тактика"}	2026-11-17 14:22:27.474016+00
344	1	1448305237	82	sell_item	{"drop_id": 234}	2026-11-14 13:32:27.301284+00
347	1	1448305237	136	sell_item	{"drop_id": 231}	2026-11-14 13:32:29.58939+00
349	1	1448305237	1260	sell_item	{"drop_id": 229}	2026-11-14 13:32:31.214066+00
354	1	1448305237	178	sell_item	{"drop_id": 224}	2026-11-14 13:32:35.473816+00
356	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:34:04.991032+00
358	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:34:17.560848+00
362	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:34:40.48443+00
364	1	1448305237	99	sell_item	{"drop_id": 253}	2026-11-14 13:36:55.809655+00
366	1	1448305237	102	sell_item	{"drop_id": 251}	2026-11-14 13:36:57.491458+00
368	1	1448305237	552	sell_item	{"drop_id": 249}	2026-11-14 13:36:59.105465+00
370	1	1448305237	65	sell_item	{"drop_id": 247}	2026-11-14 13:37:01.487077+00
371	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:37:37.261158+00
385	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:39:06.36415+00
387	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:39:26.79386+00
389	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:39:39.2543+00
417	1	1629242254	500	manual	{"reason": "addpoints command", "admin_id": 1629242254}	2026-11-14 13:41:28.778049+00
419	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:42:33.744888+00
420	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:42:39.604614+00
421	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 13:42:45.552155+00
422	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:42:51.693666+00
423	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:42:57.510508+00
424	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:43:03.89283+00
425	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:43:09.615614+00
426	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:43:15.291982+00
427	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:43:20.951695+00
428	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:43:26.733798+00
429	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:43:32.373212+00
430	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:43:38.020202+00
431	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:43:43.718845+00
432	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 13, "item_name": "AWP Азимов"}	2026-11-14 13:43:49.133624+00
433	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:43:58.976917+00
434	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:44:04.47391+00
435	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:44:10.016788+00
436	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:44:15.651223+00
437	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:44:22.45111+00
438	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:44:30.436036+00
439	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:44:36.168676+00
440	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:44:42.209677+00
441	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:44:50.918601+00
442	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:44:56.641372+00
443	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:45:02.609671+00
444	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 13:45:11.285305+00
445	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:45:17.282987+00
446	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:45:23.714401+00
447	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:45:29.289447+00
448	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:45:35.089095+00
449	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:45:40.813272+00
450	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:45:46.347874+00
451	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 13, "item_name": "AWP Азимов"}	2026-11-14 13:45:53.964165+00
452	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:45:57.546897+00
453	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:46:00.447643+00
454	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:46:03.491454+00
456	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:46:09.015145+00
458	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:46:15.765809+00
460	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:46:21.315543+00
462	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:46:27.44187+00
464	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:46:33.067025+00
466	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:46:38.570733+00
468	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:46:44.199491+00
470	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:46:49.712452+00
477	1	1629242254	110	sell_item	{"drop_id": 328}	2026-11-14 13:47:15.338758+00
479	1	1629242254	144	sell_item	{"drop_id": 326}	2026-11-14 13:47:16.097178+00
481	1	1629242254	173	sell_item	{"drop_id": 322}	2026-11-14 13:47:16.87312+00
483	1	1629242254	168	sell_item	{"drop_id": 318}	2026-11-14 13:47:17.460965+00
485	1	1629242254	289	sell_item	{"drop_id": 314}	2026-11-14 13:47:18.082823+00
487	1	1629242254	304	sell_item	{"drop_id": 310}	2026-11-14 13:47:18.715982+00
489	1	1629242254	65	sell_item	{"drop_id": 210}	2026-11-14 13:47:19.38334+00
491	1	1629242254	65	sell_item	{"drop_id": 208}	2026-11-14 13:47:20.018706+00
493	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:47:21.38582+00
494	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:47:24.721668+00
496	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:47:30.404037+00
498	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:47:35.840661+00
500	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:47:41.388376+00
502	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:47:48.521064+00
516	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:48:50.899133+00
518	1	1448305237	289	sell_item	{"drop_id": 350}	2026-11-14 13:48:57.368787+00
520	1	1448305237	365	sell_item	{"drop_id": 346}	2026-11-14 13:48:58.965179+00
522	1	1448305237	178	sell_item	{"drop_id": 341}	2026-11-14 13:49:00.919384+00
524	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:49:01.817536+00
526	1	1448305237	178	sell_item	{"drop_id": 335}	2026-11-14 13:49:03.189145+00
1270	1	1448305237	59	sell_item	{"drop_id": 878}	2026-11-16 10:05:21.914264+00
1273	1	1448305237	309	sell_item	{"drop_id": 873}	2026-11-16 10:05:24.470424+00
1278	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 130, "item_name": "Нага"}	2026-11-16 10:05:54.054432+00
1281	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 132, "item_name": "Стрелковая Дисциплина"}	2026-11-16 10:06:10.627587+00
1284	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 134, "item_name": "Синяя Фанера"}	2026-11-16 10:06:27.225752+00
1285	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 133, "item_name": "Змеиный Выпад"}	2026-11-16 10:06:32.843831+00
1325	1	965425988	224	sell_item	{"drop_id": 221}	2026-11-17 09:59:24.658311+00
1334	1	1629242254	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-17 10:03:34.763015+00
1344	1	1629242254	105	sell_item	{"drop_id": 917}	2026-11-17 14:22:25.920863+00
455	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:46:06.012126+00
457	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:46:12.146671+00
459	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:46:17.786933+00
461	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:46:23.369706+00
463	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:46:28.80012+00
465	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:46:34.475037+00
467	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:46:39.972932+00
469	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:46:45.427712+00
503	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:47:52.584118+00
505	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 13:47:58.38037+00
507	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:48:04.70386+00
509	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:48:10.964734+00
512	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:48:28.600245+00
514	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:48:39.860508+00
1271	1	1448305237	27	sell_item	{"drop_id": 877}	2026-11-16 10:05:22.789965+00
1274	1	1448305237	196	sell_item	{"drop_id": 872}	2026-11-16 10:05:25.866204+00
1276	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 131, "item_name": "Рельсотрон"}	2026-11-16 10:05:42.203126+00
1279	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 137, "item_name": "Оксидное Пламя"}	2026-11-16 10:05:59.705068+00
1282	1	1448305237	-149	case_open	{"case_id": 8, "item_id": 132, "item_name": "Стрелковая Дисциплина"}	2026-11-16 10:06:16.275404+00
1327	1	965425988	136	sell_item	{"drop_id": 910}	2026-11-17 09:59:42.961719+00
1333	1	965425988	225	sell_item	{"drop_id": 913}	2026-11-17 10:01:20.856417+00
1335	1	1448305237	500	tournament	{"rank": 1, "tournament_id": 47}	2026-11-17 10:49:30.304923+00
1336	1	1913085298	400	tournament	{"rank": 2, "tournament_id": 47}	2026-11-17 10:49:30.304923+00
1337	1	1629242254	300	tournament	{"rank": 3, "tournament_id": 47}	2026-11-17 10:49:30.304923+00
1339	1	1448305237	-129	case_open	{"case_id": 9, "item_id": 154, "item_name": "Билет в Ад"}	2026-11-17 11:18:26.179462+00
1343	1	1629242254	-129	case_open	{"case_id": 9, "item_id": 158, "item_name": "Черный Лотос"}	2026-11-17 14:22:16.952067+00
1346	1	1629242254	24	sell_item	{"drop_id": 918}	2026-11-17 14:22:33.830854+00
471	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:46:50.862909+00
473	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:46:56.263259+00
504	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:47:54.382466+00
506	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 13:48:00.972624+00
508	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:48:10.756879+00
510	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:48:16.925271+00
517	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:48:56.321954+00
519	1	1448305237	1160	sell_item	{"drop_id": 348}	2026-11-14 13:48:58.244991+00
521	1	1448305237	144	sell_item	{"drop_id": 344}	2026-11-14 13:49:00.12479+00
523	1	1448305237	173	sell_item	{"drop_id": 339}	2026-11-14 13:49:01.704563+00
525	1	1448305237	313	sell_item	{"drop_id": 337}	2026-11-14 13:49:02.429508+00
527	1	1448305237	85	sell_item	{"drop_id": 334}	2026-11-14 13:49:03.902236+00
1340	1	1448305237	31	sell_item	{"drop_id": 915}	2026-11-17 11:18:35.340837+00
472	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:46:55.163168+00
474	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 13:47:01.764833+00
475	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:47:10.204012+00
476	1	1629242254	353	sell_item	{"drop_id": 330}	2026-11-14 13:47:14.34109+00
478	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:47:15.808833+00
480	1	1629242254	136	sell_item	{"drop_id": 324}	2026-11-14 13:47:16.479312+00
482	1	1629242254	126	sell_item	{"drop_id": 320}	2026-11-14 13:47:17.158394+00
484	1	1629242254	85	sell_item	{"drop_id": 316}	2026-11-14 13:47:17.76314+00
486	1	1629242254	82	sell_item	{"drop_id": 312}	2026-11-14 13:47:18.389529+00
488	1	1629242254	85	sell_item	{"drop_id": 222}	2026-11-14 13:47:19.054148+00
490	1	1629242254	173	sell_item	{"drop_id": 209}	2026-11-14 13:47:19.698713+00
492	1	1629242254	136	sell_item	{"drop_id": 207}	2026-11-14 13:47:20.457936+00
495	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:47:27.259956+00
497	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:47:32.926966+00
499	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:47:38.546464+00
501	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:47:46.909013+00
511	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:48:23.062422+00
513	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:48:34.103166+00
515	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 13:48:45.361038+00
528	1	1448305237	136	sell_item	{"drop_id": 333}	2026-11-14 13:49:04.600536+00
529	1	1448305237	504	sell_item	{"drop_id": 332}	2026-11-14 13:49:05.268471+00
530	1	1448305237	303	sell_item	{"drop_id": 331}	2026-11-14 13:49:06.034409+00
531	1	1448305237	365	sell_item	{"drop_id": 329}	2026-11-14 13:49:06.767098+00
532	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 Пустынный повстанец"}	2026-11-14 13:49:07.262831+00
533	1	1448305237	177	sell_item	{"drop_id": 327}	2026-11-14 13:49:07.547823+00
534	1	1448305237	126	sell_item	{"drop_id": 325}	2026-11-14 13:49:08.192969+00
535	1	1448305237	225	sell_item	{"drop_id": 323}	2026-11-14 13:49:08.883469+00
536	1	1448305237	173	sell_item	{"drop_id": 321}	2026-11-14 13:49:09.544146+00
537	1	1448305237	214	sell_item	{"drop_id": 319}	2026-11-14 13:49:10.228248+00
538	1	1448305237	289	sell_item	{"drop_id": 317}	2026-11-14 13:49:10.873425+00
539	1	1448305237	136	sell_item	{"drop_id": 315}	2026-11-14 13:49:11.479503+00
540	1	1448305237	178	sell_item	{"drop_id": 313}	2026-11-14 13:49:12.117548+00
541	1	1448305237	85	sell_item	{"drop_id": 311}	2026-11-14 13:49:12.666534+00
542	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:49:12.797536+00
543	1	1448305237	600	sell_item	{"drop_id": 309}	2026-11-14 13:49:13.281941+00
544	1	1448305237	82	sell_item	{"drop_id": 308}	2026-11-14 13:49:14.046291+00
545	1	1448305237	126	sell_item	{"drop_id": 307}	2026-11-14 13:49:14.763144+00
546	1	1448305237	173	sell_item	{"drop_id": 306}	2026-11-14 13:49:15.39959+00
547	1	1448305237	78	sell_item	{"drop_id": 305}	2026-11-14 13:49:16.071108+00
548	1	1448305237	171	sell_item	{"drop_id": 304}	2026-11-14 13:49:16.790087+00
549	1	1448305237	177	sell_item	{"drop_id": 303}	2026-11-14 13:49:17.467409+00
550	1	1448305237	504	sell_item	{"drop_id": 302}	2026-11-14 13:49:18.339337+00
551	1	1448305237	102	sell_item	{"drop_id": 301}	2026-11-14 13:49:19.142491+00
552	1	1448305237	303	sell_item	{"drop_id": 300}	2026-11-14 13:49:19.920812+00
553	1	1448305237	82	sell_item	{"drop_id": 299}	2026-11-14 13:49:20.610349+00
554	1	1448305237	65	sell_item	{"drop_id": 298}	2026-11-14 13:49:21.330646+00
555	1	1448305237	173	sell_item	{"drop_id": 297}	2026-11-14 13:49:22.04678+00
556	1	1448305237	471	sell_item	{"drop_id": 296}	2026-11-14 13:49:22.85097+00
557	1	1448305237	60	sell_item	{"drop_id": 295}	2026-11-14 13:49:23.750513+00
558	1	1448305237	398	sell_item	{"drop_id": 294}	2026-11-14 13:49:24.550394+00
559	1	1448305237	126	sell_item	{"drop_id": 293}	2026-11-14 13:49:26.237669+00
560	1	1448305237	365	sell_item	{"drop_id": 292}	2026-11-14 13:49:26.971035+00
561	1	1448305237	313	sell_item	{"drop_id": 291}	2026-11-14 13:49:27.788457+00
562	1	1448305237	2142	sell_item	{"drop_id": 290}	2026-11-14 13:49:30.071591+00
563	1	1448305237	173	sell_item	{"drop_id": 289}	2026-11-14 13:49:30.908332+00
564	1	1448305237	85	sell_item	{"drop_id": 288}	2026-11-14 13:49:31.590535+00
565	1	1448305237	60	sell_item	{"drop_id": 287}	2026-11-14 13:49:32.289394+00
566	1	1448305237	85	sell_item	{"drop_id": 286}	2026-11-14 13:49:32.951174+00
567	1	1448305237	294	sell_item	{"drop_id": 285}	2026-11-14 13:49:33.653882+00
568	1	1448305237	145	sell_item	{"drop_id": 284}	2026-11-14 13:49:34.410056+00
569	1	1448305237	303	sell_item	{"drop_id": 283}	2026-11-14 13:49:35.230362+00
570	1	1448305237	126	sell_item	{"drop_id": 282}	2026-11-14 13:49:35.948181+00
571	1	1448305237	102	sell_item	{"drop_id": 281}	2026-11-14 13:49:36.589576+00
572	1	1448305237	178	sell_item	{"drop_id": 280}	2026-11-14 13:49:37.18766+00
573	1	1448305237	408	sell_item	{"drop_id": 279}	2026-11-14 13:49:37.954367+00
574	1	1448305237	65	sell_item	{"drop_id": 278}	2026-11-14 13:49:38.646774+00
575	1	1448305237	60	sell_item	{"drop_id": 277}	2026-11-14 13:49:39.356467+00
576	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:50:02.060103+00
578	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:50:13.313599+00
580	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:50:24.727774+00
581	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:50:30.161512+00
590	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:50:53.096701+00
592	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:50:58.737279+00
596	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:51:10.17498+00
598	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:51:15.851288+00
600	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:51:21.296856+00
602	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:51:29.975303+00
604	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:51:41.143778+00
606	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:51:52.006186+00
608	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 13:52:02.84958+00
610	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:52:13.882247+00
612	1	1448305237	365	sell_item	{"drop_id": 398}	2026-11-14 13:53:54.810299+00
614	1	1448305237	173	sell_item	{"drop_id": 396}	2026-11-14 13:53:56.329369+00
616	1	1448305237	239	sell_item	{"drop_id": 394}	2026-11-14 13:53:57.680036+00
618	1	1448305237	110	sell_item	{"drop_id": 392}	2026-11-14 13:53:58.810788+00
620	1	1448305237	303	sell_item	{"drop_id": 390}	2026-11-14 13:54:00.102114+00
622	1	1448305237	60	sell_item	{"drop_id": 388}	2026-11-14 13:54:02.17382+00
624	1	1448305237	173	sell_item	{"drop_id": 384}	2026-11-14 13:54:03.621401+00
626	1	1448305237	60	sell_item	{"drop_id": 380}	2026-11-14 13:54:04.995153+00
628	1	1448305237	65	sell_item	{"drop_id": 376}	2026-11-14 13:54:06.258621+00
630	1	1448305237	132	sell_item	{"drop_id": 372}	2026-11-14 13:54:07.680889+00
632	1	1448305237	214	sell_item	{"drop_id": 368}	2026-11-14 13:54:09.187474+00
634	1	1448305237	353	sell_item	{"drop_id": 366}	2026-11-14 13:54:10.587857+00
636	1	1448305237	60	sell_item	{"drop_id": 364}	2026-11-14 13:54:12.0664+00
641	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:54:50.502457+00
1347	1	965425988	500	manual	{"reason": "wipebalance", "admin_id": 965425988, "new_value": 500}	2026-11-17 15:09:05.760696+00
577	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:50:07.706981+00
579	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:50:18.869399+00
582	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:50:31.513119+00
583	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:50:35.644122+00
584	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:50:36.915582+00
585	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:50:41.093123+00
586	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:50:42.448297+00
587	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:50:46.781721+00
588	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:50:47.875555+00
589	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:50:52.259103+00
591	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:50:57.739419+00
593	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:51:03.180483+00
594	1	1629242254	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:51:04.453327+00
595	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:51:08.629106+00
597	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:51:13.920181+00
599	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:51:19.30803+00
601	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:51:24.641982+00
603	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:51:35.629903+00
605	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:51:46.659622+00
607	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:51:57.400416+00
609	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:52:08.366274+00
611	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:52:19.466568+00
613	1	1448305237	277	sell_item	{"drop_id": 397}	2026-11-14 13:53:55.631299+00
615	1	1448305237	552	sell_item	{"drop_id": 395}	2026-11-14 13:53:56.934215+00
617	1	1448305237	138	sell_item	{"drop_id": 393}	2026-11-14 13:53:58.241991+00
619	1	1448305237	85	sell_item	{"drop_id": 391}	2026-11-14 13:53:59.604842+00
621	1	1448305237	214	sell_item	{"drop_id": 389}	2026-11-14 13:54:01.244064+00
623	1	1448305237	110	sell_item	{"drop_id": 386}	2026-11-14 13:54:02.897501+00
625	1	1448305237	173	sell_item	{"drop_id": 382}	2026-11-14 13:54:04.337624+00
627	1	1448305237	177	sell_item	{"drop_id": 378}	2026-11-14 13:54:05.701561+00
629	1	1448305237	132	sell_item	{"drop_id": 374}	2026-11-14 13:54:06.961254+00
631	1	1448305237	82	sell_item	{"drop_id": 370}	2026-11-14 13:54:08.343209+00
633	1	1448305237	65	sell_item	{"drop_id": 367}	2026-11-14 13:54:09.899516+00
635	1	1448305237	60	sell_item	{"drop_id": 365}	2026-11-14 13:54:11.267589+00
637	1	1448305237	188	sell_item	{"drop_id": 363}	2026-11-14 13:54:12.877984+00
638	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:54:33.577763+00
639	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 Пустынный повстанец"}	2026-11-14 13:54:39.042287+00
640	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:54:45.061439+00
642	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:54:55.951149+00
643	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:55:01.3946+00
644	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:55:06.975241+00
645	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:55:12.492524+00
646	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:55:18.071209+00
647	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:55:23.93481+00
648	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:55:29.487673+00
649	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:55:35.000553+00
650	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:55:40.500408+00
651	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:55:45.879944+00
652	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:55:51.319614+00
653	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:55:56.718311+00
654	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:56:02.199981+00
655	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:56:07.850688+00
1348	1	1448305237	100	tournament	{"rank": 1, "tournament_id": 29}	2026-11-17 15:45:53.887488+00
656	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:56:13.239092+00
658	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:56:26.977562+00
660	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:56:44.166033+00
671	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:57:53.17098+00
673	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:58:12.401604+00
675	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 13:58:23.434378+00
677	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:58:34.675897+00
685	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:00:49.93327+00
696	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:01:59.158738+00
698	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:02:10.354398+00
700	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:02:21.443586+00
702	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:02:32.37617+00
704	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:02:43.600047+00
712	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 14:03:45.604038+00
713	1	1913085298	20	daily	{"base": 10, "bonus": 10, "streak": 2}	2026-11-14 14:29:05.925777+00
714	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:29:13.638786+00
716	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:29:28.92885+00
718	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:29:40.909484+00
727	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:32:30.337896+00
729	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:32:42.121428+00
737	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:36:50.637625+00
739	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:37:02.260848+00
741	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:37:13.837315+00
743	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 13, "item_name": "AWP Азимов"}	2026-11-14 14:37:25.258596+00
745	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:37:37.997782+00
747	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:37:49.880386+00
1349	1	1913085298	50	tournament	{"rank": 2, "tournament_id": 29}	2026-11-17 15:45:53.887488+00
657	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:56:21.106881+00
659	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:56:35.358355+00
672	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:58:01.097421+00
674	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:58:17.835563+00
676	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 13:58:29.055208+00
678	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:58:40.327342+00
680	1	8793965959	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:59:57.042206+00
683	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:00:38.797893+00
687	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:01:08.734287+00
689	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:01:19.898721+00
691	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:01:31.617856+00
693	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:01:42.730358+00
706	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:02:54.570242+00
708	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:03:05.732547+00
710	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:03:16.768782+00
731	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:32:53.45386+00
733	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:33:10.897695+00
735	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:36:36.963115+00
748	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:37:56.201859+00
750	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:38:13.710775+00
752	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:38:25.34082+00
754	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:38:37.246516+00
756	1	1913085298	173	sell_item	{"drop_id": 509}	2026-11-14 14:40:59.514251+00
758	1	1913085298	126	sell_item	{"drop_id": 506}	2026-11-14 14:41:03.256707+00
1350	1	1448305237	500	tournament	{"rank": 1, "tournament_id": 51}	2026-11-17 15:45:55.374798+00
1351	1	965425988	400	tournament	{"rank": 2, "tournament_id": 51}	2026-11-17 15:45:55.374798+00
1352	1	1629242254	300	tournament	{"rank": 3, "tournament_id": 51}	2026-11-17 15:45:55.374798+00
1357	1	1629242254	300	manual	{"reason": "wipebalance", "admin_id": 1629242254, "new_value": 300}	2026-11-17 15:48:43.462152+00
661	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:56:52.902574+00
663	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 13:57:06.901003+00
665	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:57:18.156809+00
667	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 13:57:29.547804+00
669	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 13:57:40.491306+00
679	1	8793965959	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:59:47.037448+00
684	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:00:44.332784+00
695	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:01:53.572661+00
697	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:02:04.777703+00
699	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:02:15.933657+00
701	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:02:26.994355+00
703	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:02:38.221679+00
705	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:02:49.167942+00
715	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:29:21.341758+00
717	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:29:34.93009+00
720	1	1913085298	207	sell_item	{"drop_id": 474}	2026-11-14 14:32:08.432168+00
722	1	1913085298	126	sell_item	{"drop_id": 476}	2026-11-14 14:32:10.496148+00
724	1	1913085298	188	sell_item	{"drop_id": 479}	2026-11-14 14:32:12.881635+00
726	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:32:24.482177+00
728	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 13, "item_name": "AWP Азимов"}	2026-11-14 14:32:36.099795+00
730	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:32:47.691211+00
738	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:36:56.538468+00
740	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:37:08.052267+00
742	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:37:19.567157+00
744	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:37:31.99098+00
746	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:37:44.006944+00
1353	1	1448305237	100	tournament	{"rank": 1, "tournament_id": 52}	2026-11-17 15:45:56.719499+00
1354	1	965425988	50	tournament	{"rank": 2, "tournament_id": 52}	2026-11-17 15:45:56.719499+00
662	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:56:58.724455+00
664	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 13:57:12.528384+00
666	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:57:23.427324+00
668	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 13:57:35.065962+00
670	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 13:57:47.624308+00
681	1	8793965959	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:00:09.139793+00
682	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:00:33.159682+00
686	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:01:02.975891+00
688	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:01:14.334023+00
690	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:01:25.285974+00
692	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:01:37.293936+00
694	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:01:48.165272+00
707	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:03:00.239335+00
709	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:03:11.255011+00
711	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:03:22.360493+00
719	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:29:51.076826+00
721	1	1913085298	478	sell_item	{"drop_id": 475}	2026-11-14 14:32:09.30297+00
723	1	1913085298	163	sell_item	{"drop_id": 477}	2026-11-14 14:32:11.559513+00
725	1	1913085298	325	sell_item	{"drop_id": 478}	2026-11-14 14:32:14.675071+00
732	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:32:59.170641+00
734	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:33:17.169272+00
736	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:36:43.708326+00
749	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:38:07.766326+00
751	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:38:19.654153+00
753	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:38:31.001918+00
755	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:38:43.062007+00
757	1	1913085298	149	sell_item	{"drop_id": 508}	2026-11-14 14:41:01.559527+00
759	1	1913085298	128	sell_item	{"drop_id": 505}	2026-11-14 14:41:05.408084+00
760	1	1913085298	163	sell_item	{"drop_id": 504}	2026-11-14 14:41:07.043938+00
761	1	1913085298	85	sell_item	{"drop_id": 503}	2026-11-14 14:41:08.660794+00
762	1	1913085298	178	sell_item	{"drop_id": 502}	2026-11-14 14:41:10.227862+00
763	1	1913085298	60	sell_item	{"drop_id": 500}	2026-11-14 14:41:11.978261+00
764	1	1913085298	173	sell_item	{"drop_id": 498}	2026-11-14 14:41:16.135379+00
765	1	1913085298	102	sell_item	{"drop_id": 495}	2026-11-14 14:41:19.702907+00
766	1	1913085298	82	sell_item	{"drop_id": 493}	2026-11-14 14:41:21.654209+00
767	1	1913085298	102	sell_item	{"drop_id": 494}	2026-11-14 14:41:23.456924+00
768	1	1913085298	144	sell_item	{"drop_id": 492}	2026-11-14 14:41:25.027167+00
769	1	1913085298	136	sell_item	{"drop_id": 491}	2026-11-14 14:41:26.248251+00
770	1	1913085298	128	sell_item	{"drop_id": 490}	2026-11-14 14:41:27.767495+00
771	1	1913085298	178	sell_item	{"drop_id": 487}	2026-11-14 14:41:30.633428+00
772	1	1913085298	82	sell_item	{"drop_id": 486}	2026-11-14 14:41:32.627332+00
773	1	1913085298	136	sell_item	{"drop_id": 485}	2026-11-14 14:41:35.502323+00
774	1	1913085298	82	sell_item	{"drop_id": 484}	2026-11-14 14:41:36.750015+00
775	1	1913085298	144	sell_item	{"drop_id": 483}	2026-11-14 14:41:38.40744+00
776	1	1913085298	173	sell_item	{"drop_id": 481}	2026-11-14 14:41:40.268454+00
777	1	1913085298	65	sell_item	{"drop_id": 480}	2026-11-14 14:41:41.512718+00
778	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:42:12.415856+00
779	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:42:18.544473+00
780	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:42:24.264042+00
781	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:42:30.066505+00
782	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:43:19.813382+00
783	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:43:25.670609+00
784	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:43:31.096602+00
785	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:43:36.599633+00
786	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:43:42.450129+00
787	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:43:48.060472+00
788	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:43:53.420695+00
790	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:44:04.263077+00
792	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:44:16.125063+00
794	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:44:27.118129+00
796	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:44:38.70564+00
798	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:44:49.905908+00
809	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:45:51.890895+00
811	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:46:03.386074+00
813	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:46:14.168318+00
815	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:46:25.381932+00
817	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:46:36.518222+00
819	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:46:47.656274+00
832	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:48:01.285008+00
835	1	1913085298	173	sell_item	{"drop_id": 564}	2026-11-14 14:48:20.657434+00
837	1	1913085298	145	sell_item	{"drop_id": 559}	2026-11-14 14:48:25.304974+00
839	1	1913085298	189	sell_item	{"drop_id": 556}	2026-11-14 14:48:28.831425+00
841	1	1913085298	174	sell_item	{"drop_id": 554}	2026-11-14 14:48:31.348251+00
843	1	1913085298	60	sell_item	{"drop_id": 552}	2026-11-14 14:48:33.337236+00
845	1	1913085298	126	sell_item	{"drop_id": 546}	2026-11-14 14:48:38.303803+00
847	1	1913085298	78	sell_item	{"drop_id": 543}	2026-11-14 14:48:41.873301+00
849	1	1913085298	99	sell_item	{"drop_id": 541}	2026-11-14 14:48:44.583744+00
851	1	1913085298	136	sell_item	{"drop_id": 538}	2026-11-14 14:48:47.46276+00
853	1	1913085298	178	sell_item	{"drop_id": 535}	2026-11-14 14:48:49.70405+00
874	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:49:56.995616+00
876	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:50:07.987679+00
878	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:50:19.306857+00
880	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:50:30.881668+00
882	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:50:42.157492+00
1355	1	1448305237	500	tournament	{"rank": 1, "tournament_id": 53}	2026-11-17 15:45:58.044038+00
1356	1	1629242254	400	tournament	{"rank": 2, "tournament_id": 53}	2026-11-17 15:45:58.044038+00
789	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:43:58.874619+00
791	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:44:09.866716+00
793	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:44:21.683237+00
795	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:44:32.713061+00
797	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:44:44.17797+00
810	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:45:57.362826+00
812	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:46:08.784179+00
814	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:46:19.718177+00
816	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:46:30.988742+00
818	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:46:42.054538+00
831	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:47:55.581975+00
833	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:48:06.99569+00
834	1	1913085298	60	sell_item	{"drop_id": 565}	2026-11-14 14:48:19.303657+00
836	1	1913085298	126	sell_item	{"drop_id": 562}	2026-11-14 14:48:22.62087+00
838	1	1913085298	195	sell_item	{"drop_id": 558}	2026-11-14 14:48:27.188396+00
840	1	1913085298	82	sell_item	{"drop_id": 555}	2026-11-14 14:48:30.107495+00
842	1	1913085298	60	sell_item	{"drop_id": 553}	2026-11-14 14:48:32.377978+00
844	1	1913085298	140	sell_item	{"drop_id": 549}	2026-11-14 14:48:35.720893+00
846	1	1913085298	136	sell_item	{"drop_id": 545}	2026-11-14 14:48:39.906726+00
848	1	1913085298	65	sell_item	{"drop_id": 542}	2026-11-14 14:48:43.286153+00
850	1	1913085298	60	sell_item	{"drop_id": 539}	2026-11-14 14:48:46.290494+00
852	1	1913085298	85	sell_item	{"drop_id": 537}	2026-11-14 14:48:48.503433+00
884	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:50:53.53824+00
799	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:44:55.646922+00
801	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:45:06.893685+00
803	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:45:18.385867+00
805	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:45:29.877234+00
807	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:45:40.970039+00
820	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:46:52.953501+00
822	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:47:04.132278+00
824	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:47:16.115672+00
826	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:47:27.664993+00
828	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:47:38.680777+00
830	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:47:49.967376+00
854	1	1913085298	65	sell_item	{"drop_id": 533}	2026-11-14 14:48:51.710202+00
856	1	1913085298	82	sell_item	{"drop_id": 530}	2026-11-14 14:48:54.806081+00
858	1	1913085298	60	sell_item	{"drop_id": 527}	2026-11-14 14:48:58.281252+00
860	1	1913085298	178	sell_item	{"drop_id": 524}	2026-11-14 14:49:01.201699+00
862	1	1913085298	82	sell_item	{"drop_id": 520}	2026-11-14 14:49:06.427473+00
864	1	1913085298	140	sell_item	{"drop_id": 518}	2026-11-14 14:49:08.959099+00
866	1	1913085298	65	sell_item	{"drop_id": 515}	2026-11-14 14:49:11.515715+00
868	1	1913085298	173	sell_item	{"drop_id": 513}	2026-11-14 14:49:15.877573+00
870	1	1913085298	178	sell_item	{"drop_id": 511}	2026-11-14 14:49:17.936824+00
873	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:49:51.430993+00
875	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:50:02.505777+00
877	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:50:13.670859+00
879	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:50:25.142951+00
881	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:50:36.532962+00
883	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:50:47.944849+00
800	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:45:01.363843+00
802	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:45:12.627367+00
804	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:45:24.125084+00
806	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:45:35.432767+00
808	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:45:46.482236+00
821	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:46:58.450191+00
823	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:47:10.441215+00
825	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 14:47:21.87028+00
827	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:47:33.253833+00
829	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:47:44.312761+00
855	1	1913085298	99	sell_item	{"drop_id": 532}	2026-11-14 14:48:52.967888+00
857	1	1913085298	126	sell_item	{"drop_id": 528}	2026-11-14 14:48:56.975816+00
859	1	1913085298	65	sell_item	{"drop_id": 526}	2026-11-14 14:48:59.151469+00
861	1	1913085298	178	sell_item	{"drop_id": 521}	2026-11-14 14:49:04.850899+00
863	1	1913085298	78	sell_item	{"drop_id": 519}	2026-11-14 14:49:07.485872+00
865	1	1913085298	132	sell_item	{"drop_id": 516}	2026-11-14 14:49:10.253393+00
867	1	1913085298	60	sell_item	{"drop_id": 514}	2026-11-14 14:49:12.615807+00
869	1	1913085298	178	sell_item	{"drop_id": 512}	2026-11-14 14:49:16.757227+00
871	1	1913085298	60	sell_item	{"drop_id": 510}	2026-11-14 14:49:18.958525+00
872	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:49:45.351768+00
885	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:51:01.522019+00
886	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:51:08.487224+00
887	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:51:14.649046+00
888	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:51:20.45393+00
889	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:51:26.379728+00
890	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:51:31.937822+00
891	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:51:37.493198+00
892	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:51:43.074168+00
893	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:51:48.64044+00
894	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:51:54.21924+00
895	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:51:59.933991+00
896	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:52:05.674079+00
897	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:52:11.317109+00
898	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:52:16.92186+00
899	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:52:22.499538+00
900	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:52:28.153098+00
901	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:52:33.811976+00
902	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:52:39.38157+00
903	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:52:44.883284+00
904	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:52:50.362805+00
905	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:52:56.042019+00
906	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:53:02.570406+00
907	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:53:09.021007+00
908	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:53:14.937607+00
909	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:53:20.451791+00
910	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:53:26.267971+00
911	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:53:31.815392+00
912	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:53:37.442186+00
913	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:53:43.32433+00
914	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:53:49.100248+00
915	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:53:54.859458+00
916	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:54:00.638244+00
919	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:54:17.480061+00
921	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:54:29.009264+00
923	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:54:40.298009+00
933	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:56:16.185127+00
938	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:57:55.402629+00
940	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:58:32.264733+00
947	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 15:00:12.056176+00
958	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 15:01:59.406343+00
960	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:04:21.548362+00
962	1	1913085298	163	sell_item	{"drop_id": 649}	2026-11-14 15:04:31.385+00
964	1	1913085298	65	sell_item	{"drop_id": 645}	2026-11-14 15:04:34.431012+00
966	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:04:38.121441+00
968	1	1913085298	140	sell_item	{"drop_id": 638}	2026-11-14 15:04:40.625964+00
970	1	1913085298	82	sell_item	{"drop_id": 634}	2026-11-14 15:04:44.465379+00
976	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:05:32.313308+00
978	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:05:44.226023+00
983	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:12.023571+00
985	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:17.654823+00
987	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:25.36797+00
989	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:31.20631+00
991	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:41.57806+00
996	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:07:24.9442+00
998	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:08:24.424452+00
999	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:08:49.404023+00
1007	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:11:28.706052+00
1016	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:27:12.528775+00
1019	1	1913085298	34141	sell_item	{"drop_id": 700}	2026-11-14 15:27:45.390831+00
917	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:54:06.247797+00
918	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:54:11.88686+00
920	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:54:23.202642+00
922	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:54:34.686126+00
924	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:54:45.878461+00
932	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 14:55:58.744004+00
934	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:56:45.121741+00
939	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:58:21.848846+00
948	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 15:00:27.968296+00
957	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 15:01:53.743264+00
971	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:04:52.468212+00
973	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:05:05.198361+00
977	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:05:38.103085+00
984	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:12.335572+00
986	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:22.23764+00
988	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:27.864609+00
990	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:33.360358+00
1002	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:09:34.181368+00
1003	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:10:15.561517+00
1009	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:26:17.664832+00
1011	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:26:28.950541+00
1013	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:26:40.333386+00
1021	1	1913085298	14844	sell_item	{"drop_id": 695}	2026-11-14 15:27:50.579513+00
1023	1	1913085298	31172	sell_item	{"drop_id": 694}	2026-11-14 15:27:56.5016+00
1025	1	1913085298	31172	sell_item	{"drop_id": 690}	2026-11-14 15:28:00.589178+00
1027	1	1913085298	25234	sell_item	{"drop_id": 687}	2026-11-14 15:28:03.584435+00
925	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:54:51.75234+00
927	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:55:03.0808+00
929	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 14:55:15.906318+00
930	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 14:55:21.908887+00
935	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 16, "item_name": "CZ75-Auto Сян-лю"}	2026-11-14 14:56:55.791111+00
937	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:57:42.452554+00
942	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 14:59:02.732123+00
944	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:59:25.375155+00
946	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 14:59:47.844894+00
949	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 15:01:03.028296+00
951	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 15:01:17.512186+00
952	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 14, "item_name": "USP-S Поток информации"}	2026-11-14 15:01:23.327169+00
955	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 15:01:41.208978+00
959	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:04:15.190932+00
961	1	1913085298	85	sell_item	{"drop_id": 651}	2026-11-14 15:04:29.417834+00
963	1	1913085298	82	sell_item	{"drop_id": 647}	2026-11-14 15:04:32.599386+00
965	1	1913085298	82	sell_item	{"drop_id": 643}	2026-11-14 15:04:36.602427+00
967	1	1913085298	173	sell_item	{"drop_id": 640}	2026-11-14 15:04:38.618496+00
969	1	1913085298	110	sell_item	{"drop_id": 635}	2026-11-14 15:04:42.906394+00
979	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:05:50.190624+00
982	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:06.598964+00
992	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:52.65978+00
995	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:07:12.012847+00
1000	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:09:04.942737+00
1006	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:11:23.178739+00
1015	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:27:06.184524+00
1017	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:27:18.003206+00
1018	1	1913085298	14844	sell_item	{"drop_id": 701}	2026-11-14 15:27:42.82128+00
1020	1	1913085298	14844	sell_item	{"drop_id": 699}	2026-11-14 15:27:47.632505+00
926	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:54:57.745947+00
928	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:55:08.950228+00
931	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:55:27.334151+00
936	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:57:26.997775+00
941	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 14:58:53.988288+00
943	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 14:59:18.709422+00
945	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 21, "item_name": "AWP Гадюка"}	2026-11-14 14:59:31.912264+00
950	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 15:01:10.906439+00
953	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 19, "item_name": "MP9 Latte Rush"}	2026-11-14 15:01:29.330781+00
954	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 15:01:35.689725+00
956	1	1913085298	-50	case_open	{"case_id": 3, "item_id": 9, "item_name": "АК-47 Пустынный повстанец"}	2026-11-14 15:01:47.292171+00
972	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:04:52.563293+00
974	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:05:17.107068+00
975	1	1913085298	71696	sell_item	{"drop_id": 657}	2026-11-14 15:05:21.218445+00
980	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:05:55.677453+00
981	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:01.184833+00
993	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:06:54.741552+00
994	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:07:06.387066+00
997	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:07:30.519842+00
1001	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:09:10.773541+00
1004	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:10:21.487074+00
1005	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:11:16.542242+00
1008	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:26:11.922341+00
1010	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:26:23.270391+00
1012	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:26:34.523697+00
1014	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:26:46.101668+00
1022	1	1913085298	40524	sell_item	{"drop_id": 697}	2026-11-14 15:27:53.901466+00
1024	1	1913085298	14844	sell_item	{"drop_id": 692}	2026-11-14 15:27:58.596092+00
1026	1	1913085298	31172	sell_item	{"drop_id": 688}	2026-11-14 15:28:02.100231+00
1028	1	1913085298	14844	sell_item	{"drop_id": 684}	2026-11-14 15:28:06.762251+00
1029	1	1913085298	31172	sell_item	{"drop_id": 686}	2026-11-14 15:28:08.071716+00
1030	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:29:43.554962+00
1031	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:29:49.12518+00
1032	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:29:54.787955+00
1033	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:31:38.802566+00
1034	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:32:56.327213+00
1035	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:39:27.905087+00
1036	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:39:34.30222+00
1037	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:39:40.346477+00
1038	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:39:46.727149+00
1039	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:39:53.244579+00
1040	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:39:59.291874+00
1041	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:40:05.384085+00
1042	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:40:26.936305+00
1043	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:40:33.498862+00
1044	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:40:39.456869+00
1045	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:40:45.372809+00
1046	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:40:51.780064+00
1047	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:40:58.88821+00
1049	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:41:12.847244+00
1051	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:41:24.760165+00
1053	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:44:59.30802+00
1055	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 16:11:04.475276+00
1056	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 16:18:12.914845+00
1058	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 26, "item_name": "Выстрел в Голову"}	2026-11-14 16:18:19.957038+00
1060	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 16:18:32.82792+00
1062	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 28, "item_name": "Буйство Красок"}	2026-11-14 16:18:43.895489+00
1066	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 28, "item_name": "Буйство Красок"}	2026-11-14 16:42:47.502232+00
1075	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 16:43:57.147367+00
1079	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-14 17:00:00.305404+00
1081	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 26, "item_name": "Выстрел в Голову"}	2026-11-14 17:00:11.787855+00
1083	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 31, "item_name": "Фантомный Вредитель"}	2026-11-14 17:00:23.427162+00
1085	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 29, "item_name": "Ледяной Уголь"}	2026-11-14 17:00:34.589021+00
1087	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 17:00:46.204159+00
1100	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-14 17:01:59.15199+00
1102	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 29, "item_name": "Ледяной Уголь"}	2026-11-14 17:02:14.273237+00
1104	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-14 17:02:25.502725+00
1106	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 17:02:36.48507+00
1108	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 17:02:47.565348+00
1123	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 33, "item_name": "Жгучая Ярость"}	2026-11-14 19:23:17.428571+00
1130	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 28, "item_name": "Буйство Красок"}	2026-11-14 19:24:20.361044+00
1048	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:41:06.95482+00
1050	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:41:18.877827+00
1052	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 15:41:31.396148+00
1063	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 16:18:55.218026+00
1064	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 16:42:35.472534+00
1067	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 16:42:54.080165+00
1069	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 25, "item_name": "Аквамариновая Месть"}	2026-11-14 16:43:05.564507+00
1071	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 16:43:26.584355+00
1073	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 16:43:41.414257+00
1077	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 16:59:48.592222+00
1088	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-14 17:00:51.736658+00
1090	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 17:01:02.767105+00
1092	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 25, "item_name": "Аквамариновая Месть"}	2026-11-14 17:01:14.094541+00
1094	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-14 17:01:25.391901+00
1096	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 25, "item_name": "Аквамариновая Месть"}	2026-11-14 17:01:36.887576+00
1098	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 31, "item_name": "Фантомный Вредитель"}	2026-11-14 17:01:47.932671+00
1109	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 17:02:53.00399+00
1111	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 17:03:03.840798+00
1113	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 17:03:14.841239+00
1118	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 34, "item_name": "Орбита вер.01"}	2026-11-14 19:22:49.708741+00
1120	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 37, "item_name": "Полуночный Глянец"}	2026-11-14 19:23:00.861292+00
1125	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 19:23:28.435256+00
1132	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 43, "item_name": "Затерянная Земля"}	2026-11-14 19:24:31.92883+00
1054	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 20, "item_name": "Glock-18 Зеркальная мозаика"}	2026-11-14 15:47:01.527627+00
1057	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 16:18:19.125491+00
1059	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 16:18:26.57134+00
1061	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 16:18:38.303321+00
1076	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 15, "item_name": "АК-47 Снежный вихрь"}	2026-11-14 16:44:03.141957+00
1078	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 28, "item_name": "Буйство Красок"}	2026-11-14 16:59:54.742157+00
1080	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 26, "item_name": "Выстрел в Голову"}	2026-11-14 17:00:05.868995+00
1082	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 17:00:17.676331+00
1084	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 17:00:29.045494+00
1086	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 17:00:40.14912+00
1099	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 25, "item_name": "Аквамариновая Месть"}	2026-11-14 17:01:53.556184+00
1101	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 17:02:08.622567+00
1103	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 17:02:20.011221+00
1105	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 17:02:30.942727+00
1107	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 17:02:42.010575+00
1116	1	1448305237	2129	sell_item	{"drop_id": 784}	2026-11-14 19:22:34.082306+00
1122	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-14 19:23:11.947104+00
1127	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 33, "item_name": "Жгучая Ярость"}	2026-11-14 19:23:44.860312+00
1129	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 19:24:14.57136+00
1065	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 16:42:41.485897+00
1068	1	1913085298	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 16:42:59.932031+00
1070	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 10, "item_name": "M4A1-S Золотая спираль"}	2026-11-14 16:43:09.653972+00
1072	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 18, "item_name": "MP7 Градиент"}	2026-11-14 16:43:35.678871+00
1074	1	1448305237	-50	case_open	{"case_id": 3, "item_id": 17, "item_name": "AWP Ледяной уголь"}	2026-11-14 16:43:48.25683+00
1089	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 26, "item_name": "Выстрел в Голову"}	2026-11-14 17:00:57.235667+00
1091	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 17:01:08.429388+00
1093	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 22, "item_name": "Неоновый Всадник"}	2026-11-14 17:01:19.674427+00
1095	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 17:01:30.964977+00
1097	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 26, "item_name": "Выстрел в Голову"}	2026-11-14 17:01:42.419922+00
1110	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 17:02:58.412659+00
1112	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 28, "item_name": "Буйство Красок"}	2026-11-14 17:03:09.33226+00
1114	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 17:03:20.282658+00
1115	1	1448305237	4016	sell_item	{"drop_id": 785}	2026-11-14 19:22:31.679415+00
1117	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 19:22:43.931505+00
1119	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 37, "item_name": "Полуночный Глянец"}	2026-11-14 19:22:55.229042+00
1121	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 19:23:06.394066+00
1124	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 36, "item_name": "Синий Ламинат"}	2026-11-14 19:23:22.911037+00
1126	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-14 19:23:34.512043+00
1128	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 19:23:52.942533+00
1131	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 35, "item_name": "Сланец"}	2026-11-14 19:24:26.03191+00
1133	1	1629242254	6895	sell_item	{"drop_id": 730}	2026-11-14 23:04:16.927127+00
1134	1	1629242254	11647	sell_item	{"drop_id": 728}	2026-11-14 23:04:17.875082+00
1135	1	1629242254	34141	sell_item	{"drop_id": 727}	2026-11-14 23:04:18.205939+00
1136	1	1629242254	173	sell_item	{"drop_id": 387}	2026-11-14 23:04:18.504601+00
1137	1	1629242254	303	sell_item	{"drop_id": 385}	2026-11-14 23:04:18.790494+00
1138	1	1629242254	471	sell_item	{"drop_id": 383}	2026-11-14 23:04:19.052009+00
1139	1	1629242254	224	sell_item	{"drop_id": 381}	2026-11-14 23:04:19.505941+00
1140	1	1629242254	207	sell_item	{"drop_id": 379}	2026-11-14 23:04:19.812442+00
1141	1	1629242254	395	sell_item	{"drop_id": 377}	2026-11-14 23:04:20.104503+00
1142	1	1629242254	173	sell_item	{"drop_id": 375}	2026-11-14 23:04:20.42726+00
1143	1	1629242254	110	sell_item	{"drop_id": 373}	2026-11-14 23:04:20.749643+00
1144	1	1629242254	126	sell_item	{"drop_id": 371}	2026-11-14 23:04:21.02495+00
1145	1	1629242254	303	sell_item	{"drop_id": 369}	2026-11-14 23:04:21.434184+00
1146	1	1629242254	178	sell_item	{"drop_id": 362}	2026-11-14 23:04:21.684943+00
1147	1	1629242254	400	sell_item	{"drop_id": 361}	2026-11-14 23:04:21.992174+00
1148	1	1629242254	65	sell_item	{"drop_id": 360}	2026-11-14 23:04:22.3042+00
1149	1	1629242254	60	sell_item	{"drop_id": 359}	2026-11-14 23:04:22.601365+00
1150	1	1629242254	178	sell_item	{"drop_id": 358}	2026-11-14 23:04:22.925562+00
1151	1	1629242254	325	sell_item	{"drop_id": 357}	2026-11-14 23:04:23.246936+00
1152	1	1629242254	126	sell_item	{"drop_id": 356}	2026-11-14 23:04:23.553+00
1153	1	1629242254	174	sell_item	{"drop_id": 355}	2026-11-14 23:04:23.872888+00
1154	1	1629242254	110	sell_item	{"drop_id": 354}	2026-11-14 23:04:24.202315+00
1155	1	1629242254	140	sell_item	{"drop_id": 353}	2026-11-14 23:04:24.530358+00
1156	1	1629242254	99	sell_item	{"drop_id": 352}	2026-11-14 23:04:24.852258+00
1157	1	1629242254	173	sell_item	{"drop_id": 351}	2026-11-14 23:04:25.207223+00
1158	1	1629242254	128	sell_item	{"drop_id": 349}	2026-11-14 23:04:25.505278+00
1159	1	1629242254	856	sell_item	{"drop_id": 347}	2026-11-14 23:04:25.824174+00
1160	1	1629242254	333	sell_item	{"drop_id": 345}	2026-11-14 23:04:26.194741+00
1161	1	1629242254	163	sell_item	{"drop_id": 343}	2026-11-14 23:04:26.508287+00
1162	1	1629242254	136	sell_item	{"drop_id": 342}	2026-11-14 23:04:26.86723+00
1163	1	1629242254	214	sell_item	{"drop_id": 340}	2026-11-14 23:04:27.205769+00
1164	1	1629242254	360	sell_item	{"drop_id": 338}	2026-11-14 23:04:27.523157+00
1165	1	1629242254	398	sell_item	{"drop_id": 336}	2026-11-14 23:04:27.872424+00
1166	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 23:04:34.216054+00
1167	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 23, "item_name": "Азимов"}	2026-11-14 23:04:40.262368+00
1168	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 25, "item_name": "Аквамариновая Месть"}	2026-11-14 23:04:45.856003+00
1169	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 36, "item_name": "Синий Ламинат"}	2026-11-14 23:04:51.356089+00
1170	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 41, "item_name": "Зимняя Зелень"}	2026-11-14 23:04:56.966027+00
1171	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 38, "item_name": "Колымага"}	2026-11-14 23:05:02.316991+00
1172	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 35, "item_name": "Сланец"}	2026-11-14 23:05:07.784576+00
1177	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 42, "item_name": "Элитное Снаряжение"}	2026-11-14 23:05:34.679757+00
1173	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 28, "item_name": "Буйство Красок"}	2026-11-14 23:05:13.197559+00
1178	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 36, "item_name": "Синий Ламинат"}	2026-11-14 23:05:40.961837+00
1174	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 42, "item_name": "Элитное Снаряжение"}	2026-11-14 23:05:18.755101+00
1179	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 41, "item_name": "Зимняя Зелень"}	2026-11-14 23:05:47.286518+00
1175	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 27, "item_name": "Каратель"}	2026-11-14 23:05:23.855213+00
1180	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 34, "item_name": "Орбита вер.01"}	2026-11-14 23:05:53.429499+00
1182	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 23:06:04.296843+00
1176	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 38, "item_name": "Колымага"}	2026-11-14 23:05:29.246204+00
1181	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 41, "item_name": "Зимняя Зелень"}	2026-11-14 23:05:58.785202+00
1183	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 28, "item_name": "Буйство Красок"}	2026-11-14 23:06:09.625836+00
1184	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-14 23:06:14.913058+00
1185	1	1629242254	-279	case_open	{"case_id": 4, "item_id": 29, "item_name": "Ледяной Уголь"}	2026-11-14 23:06:20.292949+00
1186	1	1448305237	100	tournament	{"rank": 1, "tournament_id": 35}	2026-11-15 00:00:58.941211+00
1187	1	1913085298	50	tournament	{"rank": 2, "tournament_id": 35}	2026-11-15 00:00:58.941211+00
1188	1	7387068552	15	daily	{"base": 10, "bonus": 5, "streak": 1}	2026-11-15 04:25:31.032631+00
1189	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 25, "item_name": "Аквамариновая Месть"}	2026-11-15 04:25:37.74689+00
1190	1	7387068552	3415	sell_item	{"drop_id": 823}	2026-11-15 04:26:41.944645+00
1191	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 47, "item_name": "Смешанный Серый"}	2026-11-15 04:27:30.331653+00
1192	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 46, "item_name": "Оливковый Поликамуфляж"}	2026-11-15 04:27:36.345995+00
1193	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 24, "item_name": "Легион Анубиса"}	2026-11-15 04:27:42.05927+00
1194	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 38, "item_name": "Колымага"}	2026-11-15 04:27:48.979861+00
1195	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-15 04:27:54.976786+00
1196	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 41, "item_name": "Зимняя Зелень"}	2026-11-15 04:28:00.644579+00
1197	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 43, "item_name": "Затерянная Земля"}	2026-11-15 04:28:06.498747+00
1198	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 40, "item_name": "Стальная Дельта"}	2026-11-15 04:28:12.215061+00
1199	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 33, "item_name": "Жгучая Ярость"}	2026-11-15 04:28:17.772739+00
1200	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 44, "item_name": "Плавный Переход"}	2026-11-15 04:28:23.435065+00
1201	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 39, "item_name": "Зеленый Глянец"}	2026-11-15 04:28:28.940691+00
1202	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 37, "item_name": "Полуночный Глянец"}	2026-11-15 04:28:34.711072+00
1203	1	7387068552	-279	case_open	{"case_id": 4, "item_id": 43, "item_name": "Затерянная Земля"}	2026-11-15 04:28:40.333444+00
1204	1	7387068552	73	sell_item	{"drop_id": 824}	2026-11-15 04:28:57.980372+00
1205	1	7387068552	838	sell_item	{"drop_id": 828}	2026-11-15 04:28:58.424669+00
1206	1	7387068552	2551	sell_item	{"drop_id": 826}	2026-11-15 04:28:59.479962+00
1207	1	7387068552	5485	sell_item	{"drop_id": 827}	2026-11-15 04:29:00.337544+00
1208	1	7387068552	34	sell_item	{"drop_id": 825}	2026-11-15 04:29:01.316288+00
1209	1	7387068552	3321	sell_item	{"drop_id": 832}	2026-11-15 04:29:01.95316+00
1210	1	7387068552	2582	sell_item	{"drop_id": 831}	2026-11-15 04:29:02.647877+00
1211	1	7387068552	6326	sell_item	{"drop_id": 834}	2026-11-15 04:29:03.28557+00
1212	1	7387068552	220	sell_item	{"drop_id": 833}	2026-11-15 04:29:03.891687+00
1213	1	7387068552	180	sell_item	{"drop_id": 836}	2026-11-15 04:29:04.579598+00
1214	1	7387068552	485	sell_item	{"drop_id": 835}	2026-11-15 04:29:05.242921+00
1215	1	7387068552	234	sell_item	{"drop_id": 830}	2026-11-15 04:29:06.969263+00
1216	1	7387068552	465	sell_item	{"drop_id": 829}	2026-11-15 04:29:07.747982+00
1217	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 44, "item_name": "Плавный Переход"}	2026-11-15 04:42:38.922379+00
1218	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 33, "item_name": "Жгучая Ярость"}	2026-11-15 04:42:45.351224+00
1219	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 44, "item_name": "Плавный Переход"}	2026-11-15 04:42:52.140274+00
1220	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 25, "item_name": "Аквамариновая Месть"}	2026-11-15 04:42:57.807206+00
1221	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 42, "item_name": "Элитное Снаряжение"}	2026-11-15 04:43:08.217966+00
1222	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 36, "item_name": "Синий Ламинат"}	2026-11-15 04:43:13.941226+00
1223	1	1448305237	7172	sell_item	{"drop_id": 840}	2026-11-15 04:49:23.840019+00
1224	1	1448305237	1419	sell_item	{"drop_id": 842}	2026-11-15 04:49:26.202047+00
1225	1	1448305237	117	sell_item	{"drop_id": 841}	2026-11-15 04:49:27.241229+00
1226	1	1448305237	153	sell_item	{"drop_id": 839}	2026-11-15 04:49:28.031316+00
1227	1	1448305237	175	sell_item	{"drop_id": 838}	2026-11-15 04:49:28.814254+00
1228	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 42, "item_name": "Элитное Снаряжение"}	2026-11-15 04:49:37.41392+00
1229	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 38, "item_name": "Колымага"}	2026-11-15 04:49:43.23817+00
1230	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 43, "item_name": "Затерянная Земля"}	2026-11-15 04:49:49.642657+00
1231	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 37, "item_name": "Полуночный Глянец"}	2026-11-15 04:49:55.402193+00
1232	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 29, "item_name": "Ледяной Уголь"}	2026-11-15 04:50:01.370032+00
1233	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 43, "item_name": "Затерянная Земля"}	2026-11-15 04:50:07.330233+00
1234	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 40, "item_name": "Стальная Дельта"}	2026-11-15 04:50:12.765156+00
1235	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 32, "item_name": "Нуво Руж"}	2026-11-15 04:50:18.30003+00
1240	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 30, "item_name": "Дилетанты"}	2026-11-15 04:50:48.37101+00
1242	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 39, "item_name": "Зеленый Глянец"}	2026-11-15 04:50:59.908312+00
1236	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 33, "item_name": "Жгучая Ярость"}	2026-11-15 04:50:25.405191+00
1241	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 39, "item_name": "Зеленый Глянец"}	2026-11-15 04:50:53.947292+00
1243	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 32, "item_name": "Нуво Руж"}	2026-11-15 04:51:05.880547+00
1237	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 42, "item_name": "Элитное Снаряжение"}	2026-11-15 04:50:31.455377+00
1244	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 32, "item_name": "Нуво Руж"}	2026-11-15 04:51:12.163642+00
1238	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 29, "item_name": "Ледяной Уголь"}	2026-11-15 04:50:37.069525+00
1239	1	1448305237	-279	case_open	{"case_id": 4, "item_id": 26, "item_name": "Выстрел в Голову"}	2026-11-15 04:50:42.72767+00
\.


--
-- Data for Name: seasons; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.seasons (id, chat_id, name, status, started_at, ended_at, rules_text, rules_enabled) FROM stdin;
1	0	Сезон 1 — Старт	active	2026-11-11 10:17:50.56096+00	\N	\N	t
\.


--
-- Data for Name: tournament_entries; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.tournament_entries (id, tournament_id, user_id, total_score, rank, reward_given) FROM stdin;
10	8	965425988	45	1	t
27	27	1629242254	7357	1	t
22	27	965425988	290	9	f
23	27	8800648129	1305	6	f
31	27	1448305237	2318	4	f
35	27	233835983	2933	3	f
39	27	8793965959	663	7	f
43	27	1913085298	6311	2	t
47	27	7756709710	1665	5	f
53	27	5714687590	370	8	f
51	31	1913085298	3632	1	t
30	30	1629242254	7357	1	t
75	50	1629242254	85	3	f
57	31	5714687590	370	4	f
46	30	1913085298	6311	2	t
26	30	8800648129	1305	6	f
34	30	1448305237	2318	4	f
38	30	233835983	2933	3	t
5	3	483243639	68	1	t
2	3	965425988	48	2	t
11	9	965425988	3320	1	t
1	2	965425988	1073	1	t
42	30	8793965959	663	7	f
4	2	483243639	68	2	t
13	9	483243639	14	2	t
61	31	965425988	2592	3	f
6	4	483243639	68	1	t
3	4	965425988	48	2	t
12	10	965425988	3320	1	t
78	50	1448305237	354	2	t
7	5	965425988	45	1	t
14	10	483243639	14	2	t
24	28	8800648129	1305	9	f
65	31	1170057607	3096	2	t
50	30	7756709710	1665	5	f
8	6	965425988	65	1	t
15	21	965425988	104	1	t
9	7	965425988	65	1	t
16	21	8800648129	4	2	t
19	23	8800648129	15	1	t
18	23	965425988	4	2	t
56	30	5714687590	370	8	f
28	28	1629242254	96714	3	t
20	25	965425988	8	1	t
52	32	1913085298	3632	1	t
21	26	965425988	290	1	t
58	32	5714687590	370	2	t
90	53	1448305237	31	1	t
86	51	1448305237	8963	1	t
36	28	233835983	2933	6	f
77	47	1448305237	1567016	1	t
40	28	8793965959	1336	8	f
76	35	1448305237	1549108	1	t
88	51	965425988	166	2	t
93	53	1629242254	0	2	t
67	35	965425988	3420	4	f
48	28	7756709710	1665	7	f
54	28	5714687590	370	10	f
59	28	965425988	6012	4	f
70	35	1629242254	88694	3	f
79	35	8793965959	673	5	f
69	48	965425988	1340	1	t
91	51	1629242254	0	3	t
72	48	1629242254	439	2	t
45	29	1913085298	1256833	2	t
81	35	1913085298	1250522	2	t
49	29	7756709710	1665	7	f
82	47	1913085298	1250522	2	t
87	52	1448305237	8963	1	t
68	47	965425988	3362	4	f
73	49	965425988	107	1	t
63	28	1170057607	3096	5	f
83	28	7387068552	0	11	f
66	33	1170057607	3096	1	t
62	33	965425988	2592	2	t
55	29	5714687590	370	10	f
60	29	965425988	5954	4	f
33	29	1448305237	1569365	1	t
89	52	965425988	166	2	t
74	50	965425988	1727	1	t
32	28	1448305237	1566866	1	t
71	47	1629242254	89357	3	t
44	28	1913085298	1256833	2	t
92	52	1629242254	0	3	f
80	47	8793965959	673	5	f
85	47	7387068552	0	6	f
25	29	8800648129	1305	9	f
29	29	1629242254	96714	3	f
37	29	233835983	2933	6	f
41	29	8793965959	1336	8	f
64	29	1170057607	3096	5	f
84	29	7387068552	0	11	f
\.


--
-- Data for Name: tournament_templates; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.tournament_templates (id, season_id, name, type, duration_hours, top_n, min_score, score_multiplier, reward_config, is_active, cron_expression, next_start_at, is_recurring, display_limit, leaderboard_labels, nickname_max_length) FROM stdin;
12	1	Новый год	custom	360	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	t	\N	\N	f	10	{}	15
14	1	Дневной блиц	custom	1	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	t	\N	\N	f	10	{}	15
11	1	Хеллуин	custom	72	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 500}, "2": {"points": 400}, "3": {"points": 300}}	t	\N	\N	f	7	{"1": "15usdt", "2": "10usdt", "3": "5usdt"}	15
8	1	Недельный бой	weekly	168	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	t	\N	\N	f	10	{}	15
10	1	Черная пятница	custom	24	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	t	\N	\N	f	10	{}	15
\.


--
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.tournaments (id, template_id, season_id, starts_at, ends_at, status, finalized_at, name, top_n, min_score, score_multiplier, reward_config, display_limit, leaderboard_labels, nickname_max_length) FROM stdin;
4	\N	1	2026-11-11 19:22:55.857961+00	2026-11-11 20:22:55.857961+00	finished	2026-11-11 20:23:06.211073+00	Тест	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
6	\N	1	2026-11-11 20:39:04.813271+00	2026-11-11 21:39:04.813271+00	finished	2026-11-11 21:39:37.83726+00	Тест	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
7	\N	1	2026-11-11 20:40:04.818345+00	2026-11-11 21:40:04.818345+00	finished	2026-11-11 21:40:37.848825+00	Те1т	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
1	\N	1	2026-11-11 18:02:28.686+00	2026-11-11 19:02:28.686+00	finished	2026-11-11 19:03:27.227817+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
10	\N	1	2026-11-11 21:51:37.847859+00	2026-11-11 22:51:37.847859+00	finished	2026-11-11 22:52:25.511401+00	0.1	10	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
2	\N	1	2026-11-11 19:04:27.228434+00	2026-11-11 20:04:27.228434+00	finished	2026-11-11 20:05:06.225524+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
31	\N	1	2026-11-13 00:00:36.783256+00	2026-11-14 00:00:36.783256+00	finished	2026-11-14 00:01:01.680069+00	Дневной блиц	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
32	\N	1	2026-11-13 00:00:36.789532+00	2026-11-13 01:00:36.789532+00	finished	2026-11-13 22:35:07.237625+00	Еще тест блица	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
27	10	1	2026-11-12 15:08:56.761249+00	2026-11-13 15:08:56.761249+00	finished	2026-11-13 22:31:21.07374+00	Черная пятница	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
36	\N	1	2026-11-14 00:00:01.688254+00	2026-11-14 01:00:01.688254+00	finished	2026-11-14 01:01:01.677596+00	Еще тест блица	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
35	\N	1	2026-11-14 00:00:01.682607+00	2026-11-15 00:00:01.682607+00	finished	2026-11-15 00:00:58.942463+00	Дневной блиц	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
28	11	1	2026-11-12 15:10:56.759229+00	2026-11-15 15:10:56.759229+00	finished	2026-11-15 15:11:25.392164+00	Хеллуин	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 500}, "2": {"points": 400}, "3": {"points": 300}}	7	{"1": "15usdt", "2": "10usdt", "3": "5usdt"}	15
29	12	1	2026-11-12 15:10:56.762735+00	2026-11-17 15:44:56.851003+00	finished	2026-11-17 15:45:53.889782+00	Новый год	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
24	\N	1	2026-11-12 12:18:17.224373+00	2026-11-12 13:18:17.224373+00	finished	2026-11-12 13:19:08.760615+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
46	\N	1	2026-11-14 09:56:01.677433+00	2026-11-14 10:56:01.677433+00	finished	2026-11-14 10:56:02.745864+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
48	\N	1	2026-11-14 10:57:02.750468+00	2026-11-14 11:57:02.750468+00	finished	2026-11-14 11:57:10.442969+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
49	\N	1	2026-11-14 11:58:10.451276+00	2026-11-14 12:31:17.318533+00	finished	2026-11-14 12:31:55.192225+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
47	11	1	2026-11-14 10:49:02.749082+00	2026-11-17 10:49:02.749082+00	finished	2026-11-17 10:49:30.306607+00	Хеллуин	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 500}, "2": {"points": 400}, "3": {"points": 300}}	7	{"1": "15usdt", "2": "10usdt", "3": "5usdt"}	15
12	\N	1	2026-11-11 23:53:03.413302+00	2026-11-12 00:53:03.413302+00	finished	2026-11-12 00:54:03.403322+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
3	\N	1	2026-11-11 19:21:55.856968+00	2026-11-11 19:43:08.180301+00	finished	2026-11-11 19:44:06.213257+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
5	\N	1	2026-11-11 19:45:06.215164+00	2026-11-11 20:45:06.215164+00	finished	2026-11-11 20:46:04.821158+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
8	\N	1	2026-11-11 20:47:04.82417+00	2026-11-11 21:47:04.82417+00	finished	2026-11-11 21:47:37.846496+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
9	\N	1	2026-11-11 21:48:37.849367+00	2026-11-11 22:48:37.849367+00	finished	2026-11-11 22:50:25.516848+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
11	\N	1	2026-11-11 22:51:25.519852+00	2026-11-11 23:51:25.519852+00	finished	2026-11-11 23:52:03.404835+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
13	\N	1	2026-11-12 00:55:03.40009+00	2026-11-12 01:55:03.40009+00	finished	2026-11-12 01:56:03.410873+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
14	\N	1	2026-11-12 01:57:03.401088+00	2026-11-12 02:57:03.401088+00	finished	2026-11-12 02:58:03.408095+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
15	\N	1	2026-11-12 02:59:03.398415+00	2026-11-12 03:59:03.398415+00	finished	2026-11-12 03:59:03.40084+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
16	\N	1	2026-11-12 04:00:03.407891+00	2026-11-12 05:00:03.407891+00	finished	2026-11-12 05:01:03.403453+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
17	\N	1	2026-11-12 05:02:03.406862+00	2026-11-12 06:02:03.406862+00	finished	2026-11-12 06:03:03.406574+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
18	\N	1	2026-11-12 06:04:03.40462+00	2026-11-12 07:04:03.40462+00	finished	2026-11-12 07:04:16.12361+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
19	\N	1	2026-11-12 07:05:53.203561+00	2026-11-12 08:05:53.203561+00	finished	2026-11-12 08:11:19.449205+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
20	\N	1	2026-11-12 08:12:50.812215+00	2026-11-12 09:12:50.812215+00	finished	2026-11-12 09:12:53.464316+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
21	\N	1	2026-11-12 09:13:53.468187+00	2026-11-12 10:13:53.468187+00	finished	2026-11-12 10:14:13.762833+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
22	\N	1	2026-11-12 10:15:13.762109+00	2026-11-12 11:15:13.762109+00	finished	2026-11-12 11:15:31.56071+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
23	\N	1	2026-11-12 11:16:31.558689+00	2026-11-12 12:16:31.558689+00	finished	2026-11-12 12:17:17.220388+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
25	\N	1	2026-11-12 13:20:08.766948+00	2026-11-12 14:20:08.766948+00	finished	2026-11-12 14:21:03.242106+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
26	\N	1	2026-11-12 14:22:03.244106+00	2026-11-12 15:22:03.244106+00	finished	2026-11-12 15:22:56.757667+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
30	\N	1	2026-11-12 15:23:56.761528+00	2026-11-12 16:23:56.761528+00	finished	2026-11-13 22:35:05.275552+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
33	\N	1	2026-11-13 22:38:59.995776+00	2026-11-13 23:38:59.995776+00	finished	2026-11-13 23:39:31.515551+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
40	\N	1	2026-11-14 03:46:01.681886+00	2026-11-14 04:46:01.681886+00	finished	2026-11-14 04:47:01.684725+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
34	\N	1	2026-11-13 23:40:31.507852+00	2026-11-14 00:40:31.507852+00	finished	2026-11-14 00:41:01.689543+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
37	\N	1	2026-11-14 00:42:01.676993+00	2026-11-14 01:42:01.676993+00	finished	2026-11-14 01:42:01.682544+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
38	\N	1	2026-11-14 01:43:01.673136+00	2026-11-14 02:43:01.673136+00	finished	2026-11-14 02:43:01.680949+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
39	\N	1	2026-11-14 02:44:01.6754+00	2026-11-14 03:44:01.6754+00	finished	2026-11-14 03:45:01.684886+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
41	\N	1	2026-11-14 04:48:01.680295+00	2026-11-14 05:48:01.680295+00	finished	2026-11-14 05:48:01.683904+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
42	\N	1	2026-11-14 05:49:01.679145+00	2026-11-14 06:49:01.679145+00	finished	2026-11-14 06:50:01.679855+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
43	\N	1	2026-11-14 06:51:01.687359+00	2026-11-14 07:51:01.687359+00	finished	2026-11-14 07:52:01.674897+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
44	\N	1	2026-11-14 07:53:01.674455+00	2026-11-14 08:53:01.674455+00	finished	2026-11-14 08:54:01.669346+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
45	\N	1	2026-11-14 08:55:01.670462+00	2026-11-14 09:55:01.670462+00	finished	2026-11-14 09:55:01.678813+00	Тестовый час	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}, "3": {"points": 20}}	10	{}	15
50	14	1	2026-11-14 12:36:55.200004+00	2026-11-14 13:36:55.200004+00	finished	2026-11-14 13:37:50.035934+00	Дневной блиц	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
51	11	1	2026-11-15 15:12:25.385591+00	2026-11-17 15:45:05.248219+00	finished	2026-11-17 15:45:55.37376+00	Хеллуин	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 500}, "2": {"points": 400}, "3": {"points": 300}}	7	{"1": "15usdt", "2": "10usdt", "3": "5usdt"}	15
52	8	1	2026-11-16 00:00:49.887557+00	2026-11-17 15:45:12.363184+00	finished	2026-11-17 15:45:56.718052+00	Недельный бой	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 100}, "2": {"points": 50}}	10	{}	15
53	11	1	2026-11-17 10:50:30.311642+00	2026-11-17 15:45:20.31565+00	finished	2026-11-17 15:45:58.042865+00	Хеллуин	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 500}, "2": {"points": 400}, "3": {"points": 300}}	7	{"1": "15usdt", "2": "10usdt", "3": "5usdt"}	15
54	11	1	2026-11-17 15:46:53.887671+00	2026-11-17 16:18:04.792692+00	finished	2026-11-17 16:18:35.987447+00	Хеллуин	3	0	{"Epic": 20, "Rare": 5, "Common": 1, "Legendary": 100}	{"1": {"points": 500}, "2": {"points": 400}, "3": {"points": 300}}	7	{"1": "15usdt", "2": "10usdt", "3": "5usdt"}	15
\.


--
-- Data for Name: user_season_stats; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.user_season_stats (id, season_id, user_id, points_balance, streak_days, last_daily_at, total_quality_score) FROM stdin;
10	1	1913085298	300	2	2026-11-14 14:29:05.924904+00	0
1	1	965425988	300	2	2026-11-14 13:08:03.84913+00	678
5	1	1448305237	300	2	2026-11-17 07:56:36.580793+00	0
4	1	1629242254	300	1	2026-11-17 10:03:34.762492+00	0
15	1	1170057607	300	1	2026-11-13 23:09:04.568048+00	0
12	1	7756709710	300	0	\N	0
3	1	8800648129	300	1	2026-11-12 10:21:39.041682+00	0
6	1	2082840699	300	0	\N	0
2	1	483243639	300	0	\N	16
7	1	233835983	300	1	2026-11-12 16:05:23.224293+00	0
14	1	5714687590	300	1	2026-11-13 16:20:43.373431+00	0
9	1	8793965959	300	1	2026-11-12 16:05:57.789885+00	0
16	1	7387068552	300	1	2026-11-15 04:25:31.031252+00	0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: casebot
--

COPY public.users (id, username, first_name, role, created_at, referred_by, is_banned, banned_at, ban_reason) FROM stdin;
965425988	dggcxd	dggcxd👾	admin	2026-11-11 11:05:22.473282+00	\N	f	\N	\N
483243639	cimpoeshdanya	Daniel	user	2026-11-11 19:35:55.412641+00	965425988	f	\N	\N
136817688	Channel_Bot	Channel	user	2026-11-12 10:40:53.358876+00	\N	f	\N	\N
8800648129	HjureZxb	Hjure	user	2026-11-12 08:11:10.054934+00	\N	f	\N	\N
8952387426	\N	\N	admin	2026-11-12 15:48:09.952095+00	\N	f	\N	\N
1629242254	\N	Кирилл	admin	2026-11-12 15:44:53.624202+00	\N	f	\N	\N
8793965959	uuu01111	U	user	2026-11-12 15:55:22.462927+00	\N	f	\N	\N
7756709710	msamoyloff	Макс Самойлов	user	2026-11-12 15:57:10.655587+00	\N	f	\N	\N
2082840699	gloob2908	Глеб	user	2026-11-12 16:02:57.353475+00	\N	f	\N	\N
233835983	alexshemskii	mé	user	2026-11-12 16:05:06.519268+00	\N	f	\N	\N
1913085298	l_1312_l	Иван Иванович	user	2026-11-12 18:21:37.389829+00	\N	f	\N	\N
5714687590	net_inform	S	user	2026-11-13 16:20:38.466726+00	\N	f	\N	\N
1170057607	yuurteezy	🫧qop	user	2026-11-13 23:08:05.597056+00	965425988	f	\N	\N
1448305237	glevvvl	glevvv	admin	2026-11-12 16:02:38.695448+00	\N	f	\N	\N
7387068552	Meghetto	Володя	user	2026-11-15 04:24:33.711859+00	\N	f	\N	\N
\.


--
-- Name: activity_reward_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.activity_reward_config_id_seq', 1, true);


--
-- Name: case_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.case_items_id_seq', 168, true);


--
-- Name: cases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.cases_id_seq', 9, true);


--
-- Name: drops_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.drops_id_seq', 918, true);


--
-- Name: manual_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.manual_rewards_id_seq', 1, false);


--
-- Name: point_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.point_transactions_id_seq', 1357, true);


--
-- Name: seasons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.seasons_id_seq', 1, true);


--
-- Name: tournament_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.tournament_entries_id_seq', 93, true);


--
-- Name: tournament_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.tournament_templates_id_seq', 14, true);


--
-- Name: tournaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.tournaments_id_seq', 54, true);


--
-- Name: user_season_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: casebot
--

SELECT pg_catalog.setval('public.user_season_stats_id_seq', 16, true);


--
-- Name: activity_reward_config activity_reward_config_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.activity_reward_config
    ADD CONSTRAINT activity_reward_config_pkey PRIMARY KEY (id);


--
-- Name: activity_reward_config activity_reward_config_season_id_key; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.activity_reward_config
    ADD CONSTRAINT activity_reward_config_season_id_key UNIQUE (season_id);


--
-- Name: case_items case_items_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.case_items
    ADD CONSTRAINT case_items_pkey PRIMARY KEY (id);


--
-- Name: cases cases_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_pkey PRIMARY KEY (id);


--
-- Name: drops drops_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.drops
    ADD CONSTRAINT drops_pkey PRIMARY KEY (id);


--
-- Name: manual_rewards manual_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.manual_rewards
    ADD CONSTRAINT manual_rewards_pkey PRIMARY KEY (id);


--
-- Name: point_transactions point_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.point_transactions
    ADD CONSTRAINT point_transactions_pkey PRIMARY KEY (id);


--
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- Name: tournament_entries tournament_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournament_entries
    ADD CONSTRAINT tournament_entries_pkey PRIMARY KEY (id);


--
-- Name: tournament_templates tournament_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournament_templates
    ADD CONSTRAINT tournament_templates_pkey PRIMARY KEY (id);


--
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (id);


--
-- Name: user_season_stats uq_season_user; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.user_season_stats
    ADD CONSTRAINT uq_season_user UNIQUE (season_id, user_id);


--
-- Name: user_season_stats user_season_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.user_season_stats
    ADD CONSTRAINT user_season_stats_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_case_items_case_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_case_items_case_id ON public.case_items USING btree (case_id);


--
-- Name: ix_cases_season_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_cases_season_id ON public.cases USING btree (season_id);


--
-- Name: ix_drops_rolled_at; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_drops_rolled_at ON public.drops USING btree (rolled_at);


--
-- Name: ix_drops_season_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_drops_season_id ON public.drops USING btree (season_id);


--
-- Name: ix_drops_user_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_drops_user_id ON public.drops USING btree (user_id);


--
-- Name: ix_point_transactions_created_at; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_point_transactions_created_at ON public.point_transactions USING btree (created_at);


--
-- Name: ix_point_transactions_season_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_point_transactions_season_id ON public.point_transactions USING btree (season_id);


--
-- Name: ix_point_transactions_user_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_point_transactions_user_id ON public.point_transactions USING btree (user_id);


--
-- Name: ix_tournament_entries_tournament_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_tournament_entries_tournament_id ON public.tournament_entries USING btree (tournament_id);


--
-- Name: ix_tournament_entries_user_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_tournament_entries_user_id ON public.tournament_entries USING btree (user_id);


--
-- Name: ix_tournament_templates_season_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_tournament_templates_season_id ON public.tournament_templates USING btree (season_id);


--
-- Name: ix_tournaments_season_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_tournaments_season_id ON public.tournaments USING btree (season_id);


--
-- Name: ix_user_season_stats_season_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_user_season_stats_season_id ON public.user_season_stats USING btree (season_id);


--
-- Name: ix_user_season_stats_user_id; Type: INDEX; Schema: public; Owner: casebot
--

CREATE INDEX ix_user_season_stats_user_id ON public.user_season_stats USING btree (user_id);


--
-- Name: activity_reward_config activity_reward_config_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.activity_reward_config
    ADD CONSTRAINT activity_reward_config_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: case_items case_items_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.case_items
    ADD CONSTRAINT case_items_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: cases cases_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.cases
    ADD CONSTRAINT cases_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: drops drops_case_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.drops
    ADD CONSTRAINT drops_case_id_fkey FOREIGN KEY (case_id) REFERENCES public.cases(id);


--
-- Name: drops drops_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.drops
    ADD CONSTRAINT drops_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.case_items(id);


--
-- Name: drops drops_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.drops
    ADD CONSTRAINT drops_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: drops drops_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.drops
    ADD CONSTRAINT drops_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: manual_rewards manual_rewards_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.manual_rewards
    ADD CONSTRAINT manual_rewards_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id);


--
-- Name: manual_rewards manual_rewards_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.manual_rewards
    ADD CONSTRAINT manual_rewards_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: point_transactions point_transactions_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.point_transactions
    ADD CONSTRAINT point_transactions_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: point_transactions point_transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.point_transactions
    ADD CONSTRAINT point_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tournament_entries tournament_entries_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournament_entries
    ADD CONSTRAINT tournament_entries_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id);


--
-- Name: tournament_entries tournament_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournament_entries
    ADD CONSTRAINT tournament_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tournament_templates tournament_templates_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournament_templates
    ADD CONSTRAINT tournament_templates_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: tournaments tournaments_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: tournaments tournaments_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.tournament_templates(id);


--
-- Name: user_season_stats user_season_stats_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.user_season_stats
    ADD CONSTRAINT user_season_stats_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: user_season_stats user_season_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: casebot
--

ALTER TABLE ONLY public.user_season_stats
    ADD CONSTRAINT user_season_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict W66XC3UqB6cEcuT3KtaG6aAGu564gPceXDdaSfbb2KNerh5m0rCXuVHWsqw4JPq

