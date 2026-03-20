Projeto de um aplicativo para registro de presença em um evento.

Telas:
 - Registro de Presença 
    - Registrar presença pelo código do aluno 
    - Permitir Leitura de QRCode
    - Permitir entrada manual (digitação)
    - Lógica especifica da tela: 
        - Os registros sempre são gravados localmente (SQLite).
        - Se o dispositivo estiver conectado a rede os registros são gravados na nuvem.

 - Sincronização
    - Sincronizar dados gravados localmente com a nuvem.
    - Sincronizar registros gravados na nuvem com a base local.
    - Logica especifica da tela:
          - Manter registro de sincronização localmente (Data, Hora, Minuto, Segundo), para as próximas sincronizaçoes. 

- Registro de Eventos.
   -Registrar um evento 
- Login 
- Recuperação de senha
- Cadastro de Usuário

Serviços:
 - Registro Local (SQLite)
 - Registro na Nuvem (Supabase/API)
 - Checagem de Serviço de Rede

Entidades:
 - Evento:
     - Nome
     - Data de início 
     - Data de fim
     - Observação 

 - Usuário:
     - Noma
     - Email

 - Aluno
    - Id 
    - Nome

 - Presença 
     - Id do Evento 
     - Id do Aluno 
     - Sincronizado (boolean)

