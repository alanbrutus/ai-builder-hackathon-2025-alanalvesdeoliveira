# 🔌 API Routes - AutoParts AI

Documentação das APIs para integração com o banco de dados SQL Server.

---

## 📋 **Endpoints Disponíveis**

### **1. Listar Grupos Empresariais**

```
GET /api/grupos
```

**Resposta:**
```json
{
  "success": true,
  "data": [
    {
      "Id": 1,
      "Nome": "Stellantis",
      "Descricao": "Grupo formado pela fusão FCA e PSA em 2021",
      "PaisOrigem": "Países Baixos",
      "AnoFundacao": 2021,
      "TotalFabricantes": 15,
      "TotalModelos": 120
    }
  ]
}
```

---

### **2. Listar Fabricantes por Grupo**

```
GET /api/fabricantes/[grupoId]
```

**Parâmetros:**
- `grupoId` (number) - ID do grupo empresarial

**Exemplo:**
```
GET /api/fabricantes/1
```

**Resposta:**
```json
{
  "success": true,
  "data": [
    {
      "Id": 8,
      "Nome": "Jeep",
      "Pais": "Estados Unidos",
      "TotalModelos": 8
    },
    {
      "Id": 7,
      "Nome": "Fiat",
      "Pais": "Itália",
      "TotalModelos": 12
    }
  ]
}
```

---

### **3. Listar Modelos por Fabricante**

```
GET /api/modelos/[fabricanteId]
```

**Parâmetros:**
- `fabricanteId` (number) - ID do fabricante

**Exemplo:**
```
GET /api/modelos/8
```

**Resposta:**
```json
{
  "success": true,
  "data": [
    {
      "Id": 1,
      "Nome": "Compass",
      "AnoInicio": 2017,
      "AnoFim": null,
      "TipoVeiculo": "SUV",
      "Periodo": "2017 - Atual"
    },
    {
      "Id": 2,
      "Nome": "Renegade",
      "AnoInicio": 2015,
      "AnoFim": null,
      "TipoVeiculo": "SUV",
      "Periodo": "2015 - Atual"
    }
  ]
}
```

---

### **4. Buscar Modelos por Nome (Autocomplete)**

```
GET /api/modelos/buscar?q=[texto]
```

**Query Parameters:**
- `q` (string) - Texto de busca (mínimo 2 caracteres)

**Exemplo:**
```
GET /api/modelos/buscar?q=Compass
```

**Resposta:**
```json
{
  "success": true,
  "data": [
    {
      "ModeloId": 1,
      "Modelo": "Compass",
      "Fabricante": "Jeep",
      "GrupoEmpresarial": "Stellantis",
      "TipoVeiculo": "SUV",
      "Periodo": "2017 - Atual",
      "NomeCompleto": "Jeep Compass",
      "HierarquiaCompleta": "Stellantis > Jeep > Compass"
    }
  ]
}
```

---

## 🔧 **Configuração**

### **1. Instalar Dependências**

```bash
npm install mssql
```

### **2. Configurar Conexão**

O arquivo `lib/db.ts` contém a configuração de conexão com o SQL Server:

```typescript
const config = {
  server: '.\\ALYASQLEXPRESS',
  database: 'AI_Builder_Hackthon',
  user: 'AI_Hackthon',
  password: '41@H4ckth0n',
  options: {
    encrypt: false,
    trustServerCertificate: true,
  },
};
```

---

## 🧪 **Testando as APIs**

### **Usando o navegador:**
```
http://localhost:3000/api/grupos
http://localhost:3000/api/fabricantes/1
http://localhost:3000/api/modelos/8
http://localhost:3000/api/modelos/buscar?q=Compass
```

### **Usando curl:**
```bash
curl http://localhost:3000/api/grupos
curl http://localhost:3000/api/fabricantes/1
curl http://localhost:3000/api/modelos/8
curl "http://localhost:3000/api/modelos/buscar?q=Compass"
```

### **Usando fetch no frontend:**
```typescript
// Listar grupos
const grupos = await fetch('/api/grupos').then(r => r.json());

// Listar fabricantes
const fabricantes = await fetch('/api/fabricantes/1').then(r => r.json());

// Listar modelos
const modelos = await fetch('/api/modelos/8').then(r => r.json());

// Buscar modelos
const busca = await fetch('/api/modelos/buscar?q=Compass').then(r => r.json());
```

---

## 📝 **Tratamento de Erros**

Todas as APIs retornam erros no formato:

```json
{
  "success": false,
  "error": "Mensagem de erro"
}
```

**Códigos de Status:**
- `200` - Sucesso
- `400` - Parâmetros inválidos
- `500` - Erro interno do servidor

---

## 🚀 **Próximos Passos**

1. Integrar as APIs no componente de chat (`app/chat/page.tsx`)
2. Criar componentes de seleção em cascata
3. Adicionar loading states
4. Implementar cache de requisições
5. Adicionar tratamento de erros na UI

---

## 📚 **Stored Procedures Utilizadas**

- `AIHT_sp_ListarGruposEmpresariais`
- `AIHT_sp_ListarFabricantesPorGrupo`
- `AIHT_sp_ListarModelosPorFabricante`
- `AIHT_sp_BuscarModelosPorNome`

Consulte `SQL/README.md` para mais detalhes sobre as procedures.
