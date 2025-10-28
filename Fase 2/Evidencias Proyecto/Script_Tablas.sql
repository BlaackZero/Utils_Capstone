-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.campaigns (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text,
  description text,
  type text,
  status text,
  budget real,
  spent real,
  start_date timestamp without time zone,
  end_date timestamp without time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  client_id bigint,
  organization_id uuid,
  CONSTRAINT campaigns_pkey PRIMARY KEY (id),
  CONSTRAINT campaigns_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id),
  CONSTRAINT campaigns_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.clients (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  isActive boolean,
  email text,
  phone text,
  updated_at timestamp with time zone,
  organization_id uuid,
  CONSTRAINT clients_pkey PRIMARY KEY (id),
  CONSTRAINT clients_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.cognitive_test_configurations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  test_type_id uuid NOT NULL,
  organization_id uuid NOT NULL,
  configuration jsonb NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  name text NOT NULL DEFAULT 'Configuración personalizada'::text,
  description text,
  is_public boolean NOT NULL DEFAULT false,
  created_by uuid NOT NULL,
  usage_count integer NOT NULL DEFAULT 0,
  tags ARRAY DEFAULT '{}'::text[],
  CONSTRAINT cognitive_test_configurations_pkey PRIMARY KEY (id),
  CONSTRAINT cognitive_test_configurations_test_type_id_fkey FOREIGN KEY (test_type_id) REFERENCES public.cognitive_test_types(id),
  CONSTRAINT cognitive_test_configurations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT cognitive_test_configurations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.cognitive_test_results (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  test_type_id uuid NOT NULL,
  configuration_id uuid,
  organization_id uuid NOT NULL,
  user_id uuid NOT NULL,
  test_configuration jsonb NOT NULL,
  raw_results jsonb NOT NULL,
  metrics jsonb NOT NULL,
  completion_time_ms integer NOT NULL,
  errors_count integer NOT NULL DEFAULT 0,
  completed boolean NOT NULL DEFAULT false,
  performance_score numeric,
  performance_level text,
  started_at timestamp with time zone NOT NULL,
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cognitive_test_results_pkey PRIMARY KEY (id),
  CONSTRAINT cognitive_test_results_test_type_id_fkey FOREIGN KEY (test_type_id) REFERENCES public.cognitive_test_types(id),
  CONSTRAINT cognitive_test_results_configuration_id_fkey FOREIGN KEY (configuration_id) REFERENCES public.cognitive_test_configurations(id),
  CONSTRAINT cognitive_test_results_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT cognitive_test_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.cognitive_test_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  version text DEFAULT '1.0'::text,
  created_at timestamp with time zone DEFAULT now(),
  category text DEFAULT 'cognitive'::text,
  difficulty_levels ARRAY DEFAULT '{easy,medium,hard}'::text[],
  default_config jsonb,
  instructions text,
  scoring_algorithm text DEFAULT 'time_and_errors'::text,
  is_active boolean DEFAULT true,
  CONSTRAINT cognitive_test_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.creator_networks (
  id integer NOT NULL DEFAULT nextval('creator_networks_id_seq'::regclass),
  creator_id integer UNIQUE,
  networks jsonb NOT NULL,
  enabled boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  organization_id uuid,
  CONSTRAINT creator_networks_pkey PRIMARY KEY (id),
  CONSTRAINT creator_networks_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT creator_networks_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id)
);
CREATE TABLE public.creators (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  username text NOT NULL,
  name text,
  last_name text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  instagram text,
  x text,
  twitch text,
  kick text,
  tiktok text,
  x_user_id text,
  organization_id uuid,
  CONSTRAINT creators_pkey PRIMARY KEY (id),
  CONSTRAINT creators_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.discord_channels (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  channel_id text NOT NULL UNIQUE,
  roster_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  game_id uuid,
  organization_id uuid,
  CONSTRAINT discord_channels_pkey PRIMARY KEY (id),
  CONSTRAINT discord_channels_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT discord_channels_roster_id_fkey FOREIGN KEY (roster_id) REFERENCES public.rosters(id),
  CONSTRAINT discord_channels_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id)
);
CREATE TABLE public.games (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT games_pkey PRIMARY KEY (id)
);
CREATE TABLE public.navigation_permissions_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  path character varying NOT NULL UNIQUE,
  name character varying NOT NULL,
  icon_name character varying,
  parent_path character varying,
  default_roles ARRAY NOT NULL DEFAULT '{}'::text[],
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT navigation_permissions_config_pkey PRIMARY KEY (id)
);
CREATE TABLE public.organization_invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  email text NOT NULL,
  role text NOT NULL DEFAULT 'member'::text CHECK (role = ANY (ARRAY['admin'::text, 'member'::text, 'viewer'::text])),
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'declined'::text])),
  invited_by uuid NOT NULL,
  invited_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone DEFAULT (now() + '7 days'::interval),
  CONSTRAINT organization_invitations_pkey PRIMARY KEY (id),
  CONSTRAINT organization_invitations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT organization_invitations_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES auth.users(id)
);
CREATE TABLE public.organization_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL DEFAULT 'member'::text CHECK (role = ANY (ARRAY['owner'::text, 'admin'::text, 'member'::text, 'viewer'::text])),
  joined_at timestamp with time zone DEFAULT now(),
  invited_by uuid,
  CONSTRAINT organization_members_pkey PRIMARY KEY (id),
  CONSTRAINT organization_members_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT organization_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT organization_members_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES auth.users(id)
);
CREATE TABLE public.organizations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  domain text,
  logo_url text,
  primary_color text,
  secondary_color text,
  subscription_plan text DEFAULT 'free'::text,
  max_users integer DEFAULT 5,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT organizations_pkey PRIMARY KEY (id)
);
CREATE TABLE public.quote_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  quote_id uuid,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  organization_id uuid,
  CONSTRAINT quote_items_pkey PRIMARY KEY (id),
  CONSTRAINT quote_items_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT quote_items_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES public.quotes(id)
);
CREATE TABLE public.quotes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  quote_number text NOT NULL,
  date date NOT NULL DEFAULT now(),
  client_name text NOT NULL,
  client_email text,
  client_phone text,
  client_address text,
  company_name text NOT NULL,
  company_logo text,
  company_address text,
  company_phone text,
  company_email text,
  subtotal numeric NOT NULL,
  tax numeric NOT NULL,
  total numeric NOT NULL,
  include_tax boolean NOT NULL DEFAULT true,
  terms text,
  created_at timestamp with time zone DEFAULT now(),
  organization_id uuid,
  CONSTRAINT quotes_pkey PRIMARY KEY (id),
  CONSTRAINT quotes_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.role_navigation_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  role character varying NOT NULL CHECK (role::text = ANY (ARRAY['admin'::character varying, 'member'::character varying, 'viewer'::character varying]::text[])),
  navigation_path character varying NOT NULL,
  has_access boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT role_navigation_permissions_pkey PRIMARY KEY (id),
  CONSTRAINT role_navigation_permissions_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT role_navigation_permissions_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.rosters (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  game_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  organization_id uuid,
  CONSTRAINT rosters_pkey PRIMARY KEY (id),
  CONSTRAINT rosters_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT rosters_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id)
);
CREATE TABLE public.scrims (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  roster_id uuid,
  opponent text,
  score_a integer,
  score_b integer,
  result text,
  map text,
  date date,
  image_url text,
  created_at timestamp with time zone DEFAULT now(),
  raw_response jsonb,
  organization_id uuid NOT NULL,
  CONSTRAINT scrims_pkey PRIMARY KEY (id),
  CONSTRAINT scrims_roster_id_fkey FOREIGN KEY (roster_id) REFERENCES public.rosters(id),
  CONSTRAINT scrims_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.slider_content (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  slider_id bigint NOT NULL,
  type text,
  content json,
  duration smallint,
  order smallint,
  visibility boolean DEFAULT true,
  CONSTRAINT slider_content_pkey PRIMARY KEY (id),
  CONSTRAINT SliderContent_slider_id_fkey FOREIGN KEY (slider_id) REFERENCES public.sliders(id)
);
CREATE TABLE public.sliders (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text,
  description text,
  platform text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  organization_id uuid,
  CONSTRAINT sliders_pkey PRIMARY KEY (id),
  CONSTRAINT sliders_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id)
);
CREATE TABLE public.social_stats (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  creator_id integer,
  network text NOT NULL,
  payload jsonb NOT NULL,
  fetched_at timestamp with time zone DEFAULT now(),
  organization_id uuid,
  CONSTRAINT social_stats_pkey PRIMARY KEY (id),
  CONSTRAINT social_stats_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
  CONSTRAINT social_stats_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  email text NOT NULL,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);