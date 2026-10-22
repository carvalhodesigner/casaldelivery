-- Casal Delivery · rode tudo no Supabase > SQL Editor
create table clientes(telefone text primary key, nome text, endereco text, referencia text);
create table pedidos(id bigint generated always as identity primary key, criado timestamptz default now(), codigo text, cliente_tel text, cliente_nome text, endereco text, referencia text, modo text, pagamento text, obs text, itens jsonb, total numeric, status int default 0);
create table config(id int primary key default 1, dados jsonb);
alter table clientes enable row level security;
alter table pedidos enable row level security;
alter table config enable row level security;
create policy "cliente cria pedido" on pedidos for insert to anon with check (status=0);
create policy "loja gerencia pedidos" on pedidos for all to authenticated using(true) with check(true);
create policy "loja gerencia clientes" on clientes for all to authenticated using(true) with check(true);
create policy "todos leem precos" on config for select using(true);
create policy "loja edita precos" on config for all to authenticated using(true) with check(true);
create function get_cliente(tel text) returns table(nome text, endereco text, referencia text) language sql security definer as $$ select nome,endereco,referencia from clientes where telefone=tel $$;
create function salvar_cliente(tel text, n text, e text, r text) returns void language sql security definer as $$ insert into clientes values(tel,n,e,r) on conflict (telefone) do update set nome=n,endereco=e,referencia=r $$;
grant execute on function get_cliente, salvar_cliente to anon;

-- Se voce JA rodou o SQL antigo, rode so esta linha em vez do bloco acima:
-- alter table pedidos add column codigo text;

-- SO NO DIA OFICIAL: trava pedidos fora do horario (dom-qui 18h-23h, sex-sab 18h-23h30)
-- drop policy "cliente cria pedido" on pedidos;
-- create policy "cliente cria pedido" on pedidos for insert to anon with check (status=0 and (
--   ((extract(dow from now() at time zone 'America/Sao_Paulo')) in (5,6) and (now() at time zone 'America/Sao_Paulo')::time between '18:00' and '23:30')
--   or ((extract(dow from now() at time zone 'America/Sao_Paulo')) not in (5,6) and (now() at time zone 'America/Sao_Paulo')::time between '18:00' and '23:00')));
