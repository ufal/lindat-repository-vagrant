--
-- PostgreSQL database dump
--


\connect "dspace-1.8.2"

--
-- Data for Name: eperson; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY eperson (eperson_id, email, password, firstname, lastname, can_log_in, require_certificate, self_registered, last_active, sub_frequency, phone, netid, language, welcome_info, last_login, can_edit_submission_metadata) FROM stdin;
1	dspace@lindat.cz	d2a147310ed200c73a5978baebf60e19	Mr.	Lindat	t	f	f	\N	\N	\N	\N	en	\N	\N	\N
\.


--
-- Name: eperson_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('eperson_seq', 1, true);


--
-- Data for Name: epersongroup; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY epersongroup (eperson_group_id, name) FROM stdin;
0	Anonymous
1	Administrator
\.


--
-- Data for Name: epersongroup2eperson; Type: TABLE DATA; Schema: public; Owner: dspace
--

COPY epersongroup2eperson (id, eperson_group_id, eperson_id) FROM stdin;
1	1	1
\.


--
-- Name: epersongroup2eperson_seq; Type: SEQUENCE SET; Schema: public; Owner: dspace
--

SELECT pg_catalog.setval('epersongroup2eperson_seq', 1, true);


