PGDMP  0            	        }            pickUpPoint    17.1    17.1 M    Q           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            R           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            S           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            T           1262    16825    pickUpPoint    DATABASE     �   CREATE DATABASE "pickUpPoint" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE "pickUpPoint";
                     postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
                     pg_database_owner    false            U           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                        pg_database_owner    false    4            �            1255    16935 -   addorder(integer, integer, character varying)    FUNCTION     y  CREATE FUNCTION public.addorder(p_cell integer, p_size integer, p_contact character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
begin

insert into orders (warehouse_id, size_id, status_id, client_contact, date_expiry) values (p_cell, p_size, 1, p_contact, NOW() + INTERVAL '7 days');
update warehouse set status_id = 2 where id = p_cell;
return 0;
end;
$$;
 \   DROP FUNCTION public.addorder(p_cell integer, p_size integer, p_contact character varying);
       public               postgres    false    4            �            1255    16928    issueorder(integer, integer)    FUNCTION       CREATE FUNCTION public.issueorder(p_id integer, p_warehouse integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
begin

update orders set warehouse_id = null, status_id = 2 where id = p_id;
update warehouse set status_id = 1 where id = p_warehouse;
return 0;
end;
$$;
 D   DROP FUNCTION public.issueorder(p_id integer, p_warehouse integer);
       public               postgres    false    4            �            1255    16923 @   newpass(character varying, character varying, character varying)    FUNCTION     J  CREATE FUNCTION public.newpass(p_login character varying, p_old_password character varying, p_new_password character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_record RECORD;
BEGIN
    SELECT * INTO user_record 
    FROM staff 
    WHERE login = p_login AND password = encode(sha256(p_old_password::bytea), 'hex');

    IF NOT FOUND THEN
        RETURN 1;
    END IF;

    UPDATE staff 
    SET password = encode(sha256(p_new_password::bytea), 'hex') 
    WHERE login = p_login;
    
    RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 1;
END;
$$;
 }   DROP FUNCTION public.newpass(p_login character varying, p_old_password character varying, p_new_password character varying);
       public               postgres    false    4            �            1255    16922 T   newstaff(character varying, character varying, character varying, character varying)    FUNCTION     w  CREATE FUNCTION public.newstaff(n_lastname character varying, n_name character varying, n_login character varying, n_password character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
begin
	insert into staff (lastname, name, role_id, login, password)
	values (n_lastname, n_name, 2, n_login, encode(sha256(n_password::bytea), 'hex'));
    RETURN 1;
END;
$$;
 �   DROP FUNCTION public.newstaff(n_lastname character varying, n_name character varying, n_login character varying, n_password character varying);
       public               postgres    false    4            �            1255    16933    writeofforder(integer, integer)    FUNCTION       CREATE FUNCTION public.writeofforder(p_id integer, p_warehouse integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
begin

update orders set warehouse_id = null, status_id = 3 where id = p_id;
update warehouse set status_id = 1 where id = p_warehouse;
return 0;
end;
$$;
 G   DROP FUNCTION public.writeofforder(p_id integer, p_warehouse integer);
       public               postgres    false    4            �            1259    16893    logs    TABLE     �   CREATE TABLE public.logs (
    id integer NOT NULL,
    who integer,
    what character varying(100),
    when_ timestamp without time zone
);
    DROP TABLE public.logs;
       public         heap r       postgres    false    4            �            1259    16892    logs_id_seq    SEQUENCE     �   CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.logs_id_seq;
       public               postgres    false    4    232            V           0    0    logs_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;
          public               postgres    false    231            �            1259    16886    orders    TABLE     �   CREATE TABLE public.orders (
    id integer NOT NULL,
    warehouse_id integer,
    size_id integer,
    status_id integer,
    client_contact character varying(50),
    date_expiry date
);
    DROP TABLE public.orders;
       public         heap r       postgres    false    4            �            1259    16885    orders_id_seq    SEQUENCE     �   CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.orders_id_seq;
       public               postgres    false    4    230            W           0    0    orders_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;
          public               postgres    false    229            �            1259    16855    size    TABLE     W   CREATE TABLE public.size (
    id integer NOT NULL,
    title character varying(15)
);
    DROP TABLE public.size;
       public         heap r       postgres    false    4            �            1259    16879    status_orders    TABLE     `   CREATE TABLE public.status_orders (
    id integer NOT NULL,
    title character varying(15)
);
 !   DROP TABLE public.status_orders;
       public         heap r       postgres    false    4            �            1259    16924    ordersonwarehouse    VIEW     B  CREATE VIEW public.ordersonwarehouse AS
 SELECT o.id,
    o.warehouse_id AS warehouse,
    s.title AS size,
    st.title AS status,
    o.client_contact,
    o.date_expiry
   FROM public.orders o,
    public.status_orders st,
    public.size s
  WHERE ((o.size_id = s.id) AND (st.id = o.status_id) AND (o.status_id = 1));
 $   DROP VIEW public.ordersonwarehouse;
       public       v       postgres    false    230    224    224    228    228    230    230    230    230    230    4            �            1259    16929    ordersonwarehouseforwriteoff    VIEW     j  CREATE VIEW public.ordersonwarehouseforwriteoff AS
 SELECT o.id,
    o.warehouse_id AS warehouse,
    s.title AS size,
    st.title AS status,
    o.client_contact,
    o.date_expiry
   FROM public.orders o,
    public.status_orders st,
    public.size s
  WHERE ((o.size_id = s.id) AND (st.id = o.status_id) AND (o.status_id = 1) AND (o.date_expiry <= now()));
 /   DROP VIEW public.ordersonwarehouseforwriteoff;
       public       v       postgres    false    230    230    230    230    230    230    224    224    228    228    4            �            1259    16827    role    TABLE     [   CREATE TABLE public.role (
    id integer NOT NULL,
    role_name character varying(25)
);
    DROP TABLE public.role;
       public         heap r       postgres    false    4            �            1259    16826    role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.role_id_seq;
       public               postgres    false    218    4            X           0    0    role_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;
          public               postgres    false    217            �            1259    16854    size_id_seq    SEQUENCE     �   CREATE SEQUENCE public.size_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.size_id_seq;
       public               postgres    false    4    224            Y           0    0    size_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.size_id_seq OWNED BY public.size.id;
          public               postgres    false    223            �            1259    16834    staff    TABLE     �   CREATE TABLE public.staff (
    id integer NOT NULL,
    lastname character varying(25),
    name character varying(25),
    role_id integer,
    login character varying(25),
    password character varying(100)
);
    DROP TABLE public.staff;
       public         heap r       postgres    false    4            �            1259    16833    staff_id_seq    SEQUENCE     �   CREATE SEQUENCE public.staff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.staff_id_seq;
       public               postgres    false    220    4            Z           0    0    staff_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.staff_id_seq OWNED BY public.staff.id;
          public               postgres    false    219            �            1259    16862    status_warehouse    TABLE     c   CREATE TABLE public.status_warehouse (
    id integer NOT NULL,
    title character varying(15)
);
 $   DROP TABLE public.status_warehouse;
       public         heap r       postgres    false    4            �            1259    16861    status_id_seq    SEQUENCE     �   CREATE SEQUENCE public.status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.status_id_seq;
       public               postgres    false    226    4            [           0    0    status_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.status_id_seq OWNED BY public.status_warehouse.id;
          public               postgres    false    225            �            1259    16878    status_orders_id_seq    SEQUENCE     �   CREATE SEQUENCE public.status_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.status_orders_id_seq;
       public               postgres    false    4    228            \           0    0    status_orders_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.status_orders_id_seq OWNED BY public.status_orders.id;
          public               postgres    false    227            �            1259    16918    users    VIEW     �   CREATE VIEW public.users AS
 SELECT s.lastname,
    s.name,
    r.role_name AS role,
    s.login,
    s.password
   FROM public.staff s,
    public.role r
  WHERE (s.role_id = r.id);
    DROP VIEW public.users;
       public       v       postgres    false    220    220    218    220    218    220    220    4            �            1259    16848 	   warehouse    TABLE     g   CREATE TABLE public.warehouse (
    id integer NOT NULL,
    size_id integer,
    status_id integer
);
    DROP TABLE public.warehouse;
       public         heap r       postgres    false    4            �            1259    16847    warehouse_id_seq    SEQUENCE     �   CREATE SEQUENCE public.warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.warehouse_id_seq;
       public               postgres    false    222    4            ]           0    0    warehouse_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.warehouse_id_seq OWNED BY public.warehouse.id;
          public               postgres    false    221            �           2604    16896    logs id    DEFAULT     b   ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);
 6   ALTER TABLE public.logs ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    231    232    232            �           2604    16889 	   orders id    DEFAULT     f   ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);
 8   ALTER TABLE public.orders ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    230    229    230            �           2604    16830    role id    DEFAULT     b   ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);
 6   ALTER TABLE public.role ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    218    217    218            �           2604    16858    size id    DEFAULT     b   ALTER TABLE ONLY public.size ALTER COLUMN id SET DEFAULT nextval('public.size_id_seq'::regclass);
 6   ALTER TABLE public.size ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    223    224    224            �           2604    16837    staff id    DEFAULT     d   ALTER TABLE ONLY public.staff ALTER COLUMN id SET DEFAULT nextval('public.staff_id_seq'::regclass);
 7   ALTER TABLE public.staff ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    219    220    220            �           2604    16882    status_orders id    DEFAULT     t   ALTER TABLE ONLY public.status_orders ALTER COLUMN id SET DEFAULT nextval('public.status_orders_id_seq'::regclass);
 ?   ALTER TABLE public.status_orders ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    227    228    228            �           2604    16865    status_warehouse id    DEFAULT     p   ALTER TABLE ONLY public.status_warehouse ALTER COLUMN id SET DEFAULT nextval('public.status_id_seq'::regclass);
 B   ALTER TABLE public.status_warehouse ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    225    226    226            �           2604    16851    warehouse id    DEFAULT     l   ALTER TABLE ONLY public.warehouse ALTER COLUMN id SET DEFAULT nextval('public.warehouse_id_seq'::regclass);
 ;   ALTER TABLE public.warehouse ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    222    221    222            N          0    16893    logs 
   TABLE DATA                 public               postgres    false    232   �[       L          0    16886    orders 
   TABLE DATA                 public               postgres    false    230   \       @          0    16827    role 
   TABLE DATA                 public               postgres    false    218   �\       F          0    16855    size 
   TABLE DATA                 public               postgres    false    224   ]       B          0    16834    staff 
   TABLE DATA                 public               postgres    false    220   o]       J          0    16879    status_orders 
   TABLE DATA                 public               postgres    false    228   �^       H          0    16862    status_warehouse 
   TABLE DATA                 public               postgres    false    226   Y_       D          0    16848 	   warehouse 
   TABLE DATA                 public               postgres    false    222   �_       ^           0    0    logs_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.logs_id_seq', 1, false);
          public               postgres    false    231            _           0    0    orders_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.orders_id_seq', 6, true);
          public               postgres    false    229            `           0    0    role_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.role_id_seq', 2, true);
          public               postgres    false    217            a           0    0    size_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.size_id_seq', 3, true);
          public               postgres    false    223            b           0    0    staff_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.staff_id_seq', 6, true);
          public               postgres    false    219            c           0    0    status_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.status_id_seq', 2, true);
          public               postgres    false    225            d           0    0    status_orders_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.status_orders_id_seq', 3, true);
          public               postgres    false    227            e           0    0    warehouse_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.warehouse_id_seq', 15, true);
          public               postgres    false    221            �           2606    16898    logs logs_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.logs DROP CONSTRAINT logs_pkey;
       public                 postgres    false    232            �           2606    16891    orders orders_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public                 postgres    false    230            �           2606    16832    role role_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.role DROP CONSTRAINT role_pkey;
       public                 postgres    false    218            �           2606    16860    size size_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.size
    ADD CONSTRAINT size_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.size DROP CONSTRAINT size_pkey;
       public                 postgres    false    224            �           2606    16841    staff staff_login_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_login_key UNIQUE (login);
 ?   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_login_key;
       public                 postgres    false    220            �           2606    16839    staff staff_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_pkey;
       public                 postgres    false    220            �           2606    16884     status_orders status_orders_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.status_orders
    ADD CONSTRAINT status_orders_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.status_orders DROP CONSTRAINT status_orders_pkey;
       public                 postgres    false    228            �           2606    16867    status_warehouse status_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.status_warehouse
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.status_warehouse DROP CONSTRAINT status_pkey;
       public                 postgres    false    226            �           2606    16853    warehouse warehouse_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.warehouse DROP CONSTRAINT warehouse_pkey;
       public                 postgres    false    222            �           2606    16904    orders orders_size_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_size_id_fkey FOREIGN KEY (size_id) REFERENCES public.size(id) NOT VALID;
 D   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_size_id_fkey;
       public               postgres    false    4764    230    224            �           2606    16909    orders orders_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.status_orders(id) NOT VALID;
 F   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_status_id_fkey;
       public               postgres    false    230    4768    228            �           2606    16899    orders orders_warehouse_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id) NOT VALID;
 I   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_warehouse_id_fkey;
       public               postgres    false    222    230    4762            �           2606    16842    staff staff_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.role(id) NOT VALID;
 B   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_role_id_fkey;
       public               postgres    false    218    4756    220            �           2606    16868     warehouse warehouse_size_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_size_id_fkey FOREIGN KEY (size_id) REFERENCES public.size(id) NOT VALID;
 J   ALTER TABLE ONLY public.warehouse DROP CONSTRAINT warehouse_size_id_fkey;
       public               postgres    false    222    224    4764            �           2606    16873 "   warehouse warehouse_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.status_warehouse(id) NOT VALID;
 L   ALTER TABLE ONLY public.warehouse DROP CONSTRAINT warehouse_status_id_fkey;
       public               postgres    false    222    4766    226            N   
   x���          L   �   x��л
�0��O����$9�'��R�V�� J��7DU��%Y>�sʺ)֭*�v�������_�ñ��������L՛��Tx�L�3�ރ����Ֆr͹��t��?=;� z�����a�d���>烅i�gx�=g{�Y�1�_}lꌠE�v<7�� a�L�p�U�%��}s�      @   G   x���v
Q���W((M��L�+��IUs�	uV�0�QPwL���S״��$���ؿ �(�$���� P��      F   B   x���v
Q���W((M��L�+άJUs�	uV�0�QP/V״��$���0���@�9 �\\ �"�      B   S  x���OJC1��=��=���W]tQ�lu?�L�P�J[=�=���z���g[\�E��7�|�p4�L��h:���4����s���׷�Iu&/���f��>��1r��ؒ5Ri)q@�$fiS&�<�^�h� Af��1�AB}~��'�
h��n�����J���Z�bc�im
�	������"��2�9!� �P�lTV�$#S@^o�6]:�bm�bDJm����wb��J��(�N�
�Z�|���eeO�pԾ���g9_������}m���Ҷ/\Ps����""��(B��w6[�ʦ$#��>��Y�3�Jޓ'��z�?n�T      J   w   x���v
Q���W((M��L�+.I,)-��/JI-*Vs�	uV�0�QP�0�����v]�}aÅ-��kZsyk�ȄI��7\�K�Vc��/6]�za�	.컰d ��MX      H   `   x���v
Q���W((M��L�+.I,)-�/O,J��/-NUs�	uV�0�QP���¦�.l�-�^ا�i��I�F 3�_�pa����M�\\ �G5�      D   t   x���v
Q���W((M��L�+O,J��/-NUs�	uV�0�Q0�Q0Դ��$F�%i�HTo��`L�z#���ޔ4��yd4	�MISnH�r#Ҕ[��U�nx#�z.. ���     