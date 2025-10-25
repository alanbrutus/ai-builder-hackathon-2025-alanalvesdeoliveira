# 🚀 Setup das APIs - Guia Rápido

## 📦 **1. Instalar Dependências**

Execute no terminal:

```bash
cd C:\TMP\ai-builder-hackathon-2025-alanalvesdeoliveira
npm install
```

Isso instalará o pacote `mssql` e todas as outras dependências.

---

## ⚙️ **2. Estrutura Criada**

```
C:\TMP\ai-builder-hackathon-2025-alanalvesdeoliveira/
├── lib/
│   └── db.ts                    # Configuração do SQL Server
├── app/
│   └── api/
│       ├── grupos/
│       │   └── route.ts         # GET /api/grupos
│       ├── fabricantes/
│       │   └── [grupoId]/
│       │       └── route.ts     # GET /api/fabricantes/[id]
│       └── modelos/
│           ├── [fabricanteId]/
│           │   └── route.ts     # GET /api/modelos/[id]
│           └── buscar/
│               └── route.ts     # GET /api/modelos/buscar?q=texto
```

---

## 🧪 **3. Testar as APIs**

### **Iniciar o servidor:**
```bash
npm run dev
```

### **Testar no navegador:**

Abra estas URLs:

1. **Listar grupos:**
   ```
   http://localhost:3000/api/grupos
   ```

2. **Listar fabricantes do Stellantis (ID=1):**
   ```
   http://localhost:3000/api/fabricantes/1
   ```

3. **Listar modelos da Jeep (ID=8):**
   ```
   http://localhost:3000/api/modelos/8
   ```

4. **Buscar modelo "Compass":**
   ```
   http://localhost:3000/api/modelos/buscar?q=Compass
   ```

---

## 🔍 **4. Verificar Erros**

Se houver erros de conexão, verifique:

### **SQL Server está rodando?**
```bash
# Verificar serviço
Get-Service -Name "MSSQL$ALYASQLEXPRESS"

# Iniciar se necessário
Start-Service -Name "MSSQL$ALYASQLEXPRESS"
```

### **Credenciais corretas?**
Verifique em `lib/db.ts`:
- Server: `.\ALYASQLEXPRESS`
- Database: `AI_Builder_Hackthon`
- User: `AI_Hackthon`
- Password: `41@H4ckth0n`

---

## 📝 **5. Próximos Passos**

Após confirmar que as APIs estão funcionando:

1. ✅ Atualizar componente de chat para usar as APIs
2. ✅ Criar seleção em cascata (Grupo → Fabricante → Modelo)
3. ✅ Adicionar loading states
4. ✅ Integrar com IA (OpenAI/Claude)

---

## 🐛 **Troubleshooting**

### **Erro: "Cannot find module 'mssql'"**
```bash
npm install mssql
```

### **Erro: "Login failed for user"**
Execute no SSMS:
```sql
USE AI_Builder_Hackthon;
GRANT SELECT, EXECUTE ON SCHEMA::dbo TO AI_Hackthon;
```

### **Erro: "Cannot connect to server"**
- Verifique se o SQL Server está rodando
- Confirme o nome da instância: `.\ALYASQLEXPRESS`
- Verifique se TCP/IP está habilitado no SQL Server Configuration Manager

---

## 📚 **Documentação Completa**

Consulte `app/api/README.md` para documentação detalhada de cada endpoint.
