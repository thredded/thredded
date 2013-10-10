--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.4
-- Dumped by pg_dump version 9.0.4
-- Started on 2013-10-10 11:50:13 PDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 1953 (class 0 OID 0)
-- Dependencies: 1553
-- Name: thredded_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_attachments_id_seq', 1, false);


--
-- TOC entry 1954 (class 0 OID 0)
-- Dependencies: 1555
-- Name: thredded_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_categories_id_seq', 1, false);


--
-- TOC entry 1955 (class 0 OID 0)
-- Dependencies: 1557
-- Name: thredded_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_images_id_seq', 1, false);


--
-- TOC entry 1956 (class 0 OID 0)
-- Dependencies: 1567
-- Name: thredded_messageboard_preferences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_messageboard_preferences_id_seq', 1, true);


--
-- TOC entry 1957 (class 0 OID 0)
-- Dependencies: 1559
-- Name: thredded_messageboards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_messageboards_id_seq', 1, true);


--
-- TOC entry 1958 (class 0 OID 0)
-- Dependencies: 1561
-- Name: thredded_post_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_post_notifications_id_seq', 1, false);


--
-- TOC entry 1959 (class 0 OID 0)
-- Dependencies: 1563
-- Name: thredded_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_posts_id_seq', 12, true);


--
-- TOC entry 1960 (class 0 OID 0)
-- Dependencies: 1565
-- Name: thredded_private_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_private_users_id_seq', 1, false);


--
-- TOC entry 1961 (class 0 OID 0)
-- Dependencies: 1569
-- Name: thredded_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_roles_id_seq', 1, true);


--
-- TOC entry 1962 (class 0 OID 0)
-- Dependencies: 1571
-- Name: thredded_topic_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_topic_categories_id_seq', 1, false);


--
-- TOC entry 1963 (class 0 OID 0)
-- Dependencies: 1573
-- Name: thredded_topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_topics_id_seq', 4, true);


--
-- TOC entry 1964 (class 0 OID 0)
-- Dependencies: 1575
-- Name: thredded_user_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_user_details_id_seq', 1, false);


--
-- TOC entry 1965 (class 0 OID 0)
-- Dependencies: 1577
-- Name: thredded_user_preferences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_user_preferences_id_seq', 1, false);


--
-- TOC entry 1966 (class 0 OID 0)
-- Dependencies: 1579
-- Name: thredded_user_topic_reads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('thredded_user_topic_reads_id_seq', 73, true);


--
-- TOC entry 1967 (class 0 OID 0)
-- Dependencies: 1551
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('users_id_seq', 5, true);


--
-- TOC entry 1937 (class 0 OID 138698)
-- Dependencies: 1554
-- Data for Name: thredded_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_attachments (id, attachment, content_type, file_size, post_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 1938 (class 0 OID 138709)
-- Dependencies: 1556
-- Data for Name: thredded_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_categories (id, messageboard_id, name, description, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 1939 (class 0 OID 138720)
-- Dependencies: 1558
-- Data for Name: thredded_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_images (id, post_id, width, height, orientation, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 1944 (class 0 OID 138774)
-- Dependencies: 1568
-- Data for Name: thredded_messageboard_preferences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_messageboard_preferences (id, notify_on_mention, notify_on_message, filter, user_id, messageboard_id, created_at, updated_at) FROM stdin;
1	t	t	markdown	2	1	2013-10-08 01:21:50.310057	2013-10-08 01:21:50.310057
\.


--
-- TOC entry 1940 (class 0 OID 138728)
-- Dependencies: 1560
-- Data for Name: thredded_messageboards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_messageboards (id, name, slug, description, security, posting_permission, topics_count, posts_count, closed, created_at, updated_at) FROM stdin;
1	babyone	babyone	My first baby	public	anonymous	4	12	f	2013-10-07 19:08:06.549169	2013-10-10 18:45:40.159794
\.


--
-- TOC entry 1941 (class 0 OID 138745)
-- Dependencies: 1562
-- Data for Name: thredded_post_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_post_notifications (id, email, post_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 1942 (class 0 OID 138753)
-- Dependencies: 1564
-- Data for Name: thredded_posts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_posts (id, user_id, user_email, content, ip, filter, source, topic_id, messageboard_id, created_at, updated_at) FROM stdin;
1	1	\N	There's not a whole lot here for now.	127.0.0.1	markdown	web	1	1	2013-10-07 19:08:06.934821	2013-10-07 19:08:06.934821
2	1	\N	The last one I made didn't have one and I couldn't get to it.	127.0.0.1	bbcode	web	2	1	2013-10-07 19:14:47.903547	2013-10-07 19:14:47.903547
4	2	\N	And another	127.0.0.1	markdown	web	2	1	2013-10-07 22:54:58.236122	2013-10-07 22:54:58.236122
5	2	\N	And one with an attachment	127.0.0.1	bbcode	web	2	1	2013-10-07 22:55:54.768635	2013-10-07 22:55:54.768635
6	2	\N	# yes	127.0.0.1	markdown	web	2	1	2013-10-07 22:55:59.794884	2013-10-07 22:55:59.794884
7	2	\N	* bullet?\r\n* bullet.	127.0.0.1	markdown	web	2	1	2013-10-07 22:56:11.501555	2013-10-07 22:56:11.501555
8	2	\N	bbcode now\r\n* bullet?\r\n* bullet.	127.0.0.1	bbcode	web	2	1	2013-10-07 22:56:27.55133	2013-10-07 22:56:27.55133
3	2	\N	Here is another reply!!!	127.0.0.1	markdown	web	2	1	2013-10-07 22:54:51.638945	2013-10-07 23:10:03.142785
9	1	\N	Yeah! PRivate!	127.0.0.1	markdown	web	3	1	2013-10-08 00:56:03.649586	2013-10-08 00:56:03.649586
11	2	\N	sadfdsa asdfasdf !!!	127.0.0.1	markdown	web	2	1	2013-10-08 01:15:13.354399	2013-10-08 01:15:13.354399
10	2	\N	Hey this is new\r\n* YEAH2	127.0.0.1	markdown	web	2	1	2013-10-08 01:14:02.931663	2013-10-08 01:15:57.516732
12	2	\N	* bullet in the head	127.0.0.1	markdown	web	4	1	2013-10-10 18:45:40.118004	2013-10-10 18:45:40.118004
\.


--
-- TOC entry 1943 (class 0 OID 138766)
-- Dependencies: 1566
-- Data for Name: thredded_private_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_private_users (id, private_topic_id, user_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 1945 (class 0 OID 138787)
-- Dependencies: 1570
-- Data for Name: thredded_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_roles (id, level, user_id, messageboard_id, last_seen, created_at, updated_at) FROM stdin;
1	admin	1	1	2013-10-08 03:08:47.416973	2013-10-07 19:08:06.588643	2013-10-08 03:08:47.417457
\.


--
-- TOC entry 1946 (class 0 OID 138797)
-- Dependencies: 1572
-- Data for Name: thredded_topic_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_topic_categories (id, topic_id, category_id) FROM stdin;
\.


--
-- TOC entry 1947 (class 0 OID 138805)
-- Dependencies: 1574
-- Data for Name: thredded_topics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_topics (id, user_id, last_user_id, title, slug, messageboard_id, posts_count, sticky, locked, hash_id, state, type, created_at, updated_at) FROM stdin;
1	1	1	Welcome to your messageboard's very first thread	welcome-to-your-messageboard-s-very-first-thread	1	1	f	f	dc5850662d32173cea0c	approved	\N	2013-10-07 19:08:06.931997	2013-10-07 19:08:07.019221
3	1	1	Here is a private topic	here-is-a-private-topic	1	1	f	f	9bace4228090387678ec	approved	\N	2013-10-08 00:56:03.623544	2013-10-08 00:56:03.661876
2	1	2	Need to make sure slug gets set when creating a new messageboard	need-to-make-sure-slug-gets-set-when-creating-a-new-messageboard	1	9	f	f	1f3f5c5e921823449d8a	approved	\N	2013-10-07 19:14:47.901338	2013-10-08 01:15:13.369639
4	2	2	'nother	nother	1	1	f	f	f2b759bb0c59d8705fcb	approved	\N	2013-10-10 18:45:40.096446	2013-10-10 18:45:40.146367
\.


--
-- TOC entry 1948 (class 0 OID 138821)
-- Dependencies: 1576
-- Data for Name: thredded_user_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_user_details (id, user_id, latest_activity_at, posts_count, topics_count, superadmin, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 1949 (class 0 OID 138834)
-- Dependencies: 1578
-- Data for Name: thredded_user_preferences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_user_preferences (id, user_id, time_zone, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 1950 (class 0 OID 138844)
-- Dependencies: 1580
-- Data for Name: thredded_user_topic_reads; Type: TABLE DATA; Schema: public; Owner: -
--

COPY thredded_user_topic_reads (id, user_id, topic_id, post_id, posts_count, page, created_at, updated_at) FROM stdin;
1	1	2	2	1	1	2013-10-07 19:14:53.421146	2013-10-07 19:14:53.421146
2	1	1	1	1	1	2013-10-07 19:14:56.783633	2013-10-07 19:14:56.783633
3	2	2	2	1	1	2013-10-07 22:54:32.74834	2013-10-07 22:54:32.74834
4	2	2	3	2	1	2013-10-07 22:54:51.698826	2013-10-07 22:54:51.698826
5	2	2	4	3	1	2013-10-07 22:54:58.269018	2013-10-07 22:54:58.269018
6	2	2	5	4	1	2013-10-07 22:55:54.803071	2013-10-07 22:55:54.803071
7	2	2	6	5	1	2013-10-07 22:55:59.828736	2013-10-07 22:55:59.828736
8	2	2	7	6	1	2013-10-07 22:56:11.535301	2013-10-07 22:56:11.535301
9	2	2	8	7	1	2013-10-07 22:56:27.585113	2013-10-07 22:56:27.585113
10	2	2	8	7	1	2013-10-07 22:58:41.131593	2013-10-07 22:58:41.131593
11	2	2	8	7	1	2013-10-07 23:09:55.375979	2013-10-07 23:09:55.375979
12	2	2	8	7	1	2013-10-07 23:10:03.169639	2013-10-07 23:10:03.169639
13	2	2	8	7	1	2013-10-08 00:59:04.835204	2013-10-08 00:59:04.835204
14	2	2	8	7	1	2013-10-08 00:59:38.374633	2013-10-08 00:59:38.374633
15	2	2	8	7	1	2013-10-08 01:06:12.399582	2013-10-08 01:06:12.399582
16	2	2	8	7	1	2013-10-08 01:09:21.865826	2013-10-08 01:09:21.865826
17	2	2	10	8	1	2013-10-08 01:14:03.034735	2013-10-08 01:14:03.034735
18	2	2	11	9	1	2013-10-08 01:15:13.510798	2013-10-08 01:15:13.510798
19	2	2	11	9	1	2013-10-08 01:15:57.545428	2013-10-08 01:15:57.545428
20	2	2	11	9	1	2013-10-08 01:16:23.472509	2013-10-08 01:16:23.472509
21	2	2	11	9	1	2013-10-08 01:16:28.687092	2013-10-08 01:16:28.687092
22	1	2	11	9	1	2013-10-08 02:48:26.599554	2013-10-08 02:48:26.599554
23	1	2	11	9	1	2013-10-08 02:50:53.633509	2013-10-08 02:50:53.633509
24	1	2	11	9	1	2013-10-08 02:51:03.983297	2013-10-08 02:51:03.983297
25	1	2	11	9	1	2013-10-08 02:51:12.394532	2013-10-08 02:51:12.394532
26	1	2	11	9	1	2013-10-08 02:52:19.059746	2013-10-08 02:52:19.059746
27	1	2	11	9	1	2013-10-08 02:53:16.508913	2013-10-08 02:53:16.508913
28	1	2	11	9	1	2013-10-08 02:54:06.651681	2013-10-08 02:54:06.651681
29	1	2	11	9	1	2013-10-08 02:54:30.017674	2013-10-08 02:54:30.017674
30	1	2	11	9	1	2013-10-08 02:55:00.225931	2013-10-08 02:55:00.225931
31	1	2	11	9	1	2013-10-08 02:55:02.492287	2013-10-08 02:55:02.492287
32	1	2	11	9	1	2013-10-08 02:55:41.378216	2013-10-08 02:55:41.378216
33	1	2	11	9	1	2013-10-08 02:55:46.754222	2013-10-08 02:55:46.754222
34	1	2	11	9	1	2013-10-08 02:56:26.174821	2013-10-08 02:56:26.174821
35	1	2	11	9	1	2013-10-08 02:56:34.052244	2013-10-08 02:56:34.052244
36	1	2	11	9	1	2013-10-08 02:57:18.636247	2013-10-08 02:57:18.636247
37	1	2	11	9	1	2013-10-08 02:57:51.565164	2013-10-08 02:57:51.565164
38	1	2	11	9	1	2013-10-08 02:58:29.605913	2013-10-08 02:58:29.605913
39	1	2	11	9	1	2013-10-08 02:58:44.078903	2013-10-08 02:58:44.078903
40	1	2	11	9	1	2013-10-08 02:59:26.242568	2013-10-08 02:59:26.242568
41	1	2	11	9	1	2013-10-08 02:59:33.590547	2013-10-08 02:59:33.590547
42	1	2	11	9	1	2013-10-08 02:59:56.088324	2013-10-08 02:59:56.088324
43	1	2	11	9	1	2013-10-08 03:00:47.372693	2013-10-08 03:00:47.372693
44	1	2	11	9	1	2013-10-08 03:00:56.508611	2013-10-08 03:00:56.508611
45	1	2	11	9	1	2013-10-08 03:01:21.055051	2013-10-08 03:01:21.055051
46	1	2	11	9	1	2013-10-08 03:01:34.904257	2013-10-08 03:01:34.904257
47	1	2	11	9	1	2013-10-08 03:01:44.796167	2013-10-08 03:01:44.796167
48	1	2	11	9	1	2013-10-08 03:02:30.637966	2013-10-08 03:02:30.637966
49	1	2	11	9	1	2013-10-08 03:02:33.218686	2013-10-08 03:02:33.218686
50	1	2	11	9	1	2013-10-08 03:02:40.25357	2013-10-08 03:02:40.25357
51	1	2	11	9	1	2013-10-08 03:03:19.706289	2013-10-08 03:03:19.706289
52	1	2	11	9	1	2013-10-08 03:03:30.371185	2013-10-08 03:03:30.371185
53	1	2	11	9	1	2013-10-08 03:03:43.450465	2013-10-08 03:03:43.450465
54	1	2	11	9	1	2013-10-08 03:03:56.285374	2013-10-08 03:03:56.285374
55	1	2	11	9	1	2013-10-08 03:04:01.37258	2013-10-08 03:04:01.37258
56	1	2	11	9	1	2013-10-08 03:04:06.419546	2013-10-08 03:04:06.419546
57	1	2	11	9	1	2013-10-08 03:04:10.85187	2013-10-08 03:04:10.85187
58	1	2	11	9	1	2013-10-08 03:04:20.199678	2013-10-08 03:04:20.199678
59	1	2	11	9	1	2013-10-08 03:04:36.609599	2013-10-08 03:04:36.609599
60	1	2	11	9	1	2013-10-08 03:04:51.755536	2013-10-08 03:04:51.755536
61	1	2	11	9	1	2013-10-08 03:05:00.2479	2013-10-08 03:05:00.2479
62	1	2	11	9	1	2013-10-08 03:05:15.404386	2013-10-08 03:05:15.404386
63	1	2	11	9	1	2013-10-08 03:05:39.75043	2013-10-08 03:05:39.75043
64	1	2	11	9	1	2013-10-08 03:06:06.635446	2013-10-08 03:06:06.635446
65	1	2	11	9	1	2013-10-08 03:06:18.835196	2013-10-08 03:06:18.835196
66	1	2	11	9	1	2013-10-08 03:06:37.489168	2013-10-08 03:06:37.489168
67	1	2	11	9	1	2013-10-08 03:06:59.341302	2013-10-08 03:06:59.341302
68	1	2	11	9	1	2013-10-08 03:08:20.855969	2013-10-08 03:08:20.855969
69	1	2	11	9	1	2013-10-08 03:08:26.217354	2013-10-08 03:08:26.217354
70	1	2	11	9	1	2013-10-08 03:08:45.063231	2013-10-08 03:08:45.063231
71	2	2	11	9	1	2013-10-10 18:10:47.479578	2013-10-10 18:10:47.479578
72	2	2	11	9	1	2013-10-10 18:45:11.434103	2013-10-10 18:45:11.434103
73	2	4	12	1	1	2013-10-10 18:45:42.603583	2013-10-10 18:45:42.603583
\.


--
-- TOC entry 1936 (class 0 OID 138687)
-- Dependencies: 1552
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY users (id, name, email, created_at, updated_at) FROM stdin;
1	Bergen Moore	\N	2013-10-07 18:55:05.221473	2013-10-07 18:55:05.221473
2	Joe	\N	2013-10-07 22:23:46.374152	2013-10-07 22:23:46.374152
3	Phil	\N	2013-10-08 00:32:53.708179	2013-10-08 00:32:53.708179
4	Bergen	\N	2013-10-08 00:52:32.292162	2013-10-08 00:52:32.292162
5	Foo	\N	2013-10-08 00:56:23.662558	2013-10-08 00:56:23.662558
\.


-- Completed on 2013-10-10 11:50:13 PDT

--
-- PostgreSQL database dump complete
--

