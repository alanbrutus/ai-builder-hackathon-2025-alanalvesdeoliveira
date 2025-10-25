# 🏢 Hierarquia de Grupos Empresariais - Seleção em Cascata

## 📋 Visão Geral

Este documento descreve a implementação da hierarquia **Grupo Empresarial → Fabricante → Modelo** para permitir seleção em cascata no chat com IA.

---

## 🎯 Hierarquia Correta

```
GRUPO EMPRESARIAL (Stellantis, Volkswagen Group, General Motors, etc.)
    └── FABRICANTE (Jeep, Fiat, Peugeot, Chevrolet, etc.)
            └── MODELO (Compass, Renegade, Onix, etc.)
```

### **Exemplo: Stellantis**

```
Stellantis (Grupo Empresarial)
    ├── Abarth
    ├── Alfa Romeo
    ├── Chrysler
    ├── Citroën
    ├── Dodge
    ├── DS
    ├── Fiat
    ├── Jeep
    │   ├── Compass
    │   ├── Renegade
    │   ├── Commander
    │   └── Wrangler
    ├── Lancia
    ├── Maserati
    ├── Opel
    ├── Peugeot
    ├── Ram
    ├── Vauxhall
    └── Leapmotor
```

---

## 🏗️ Estrutura do Banco de Dados

### **Nova Tabela: `AIHT_GruposEmpresariais`**

```sql
CREATE TABLE AIHT_GruposEmpresariais (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome NVARCHAR(100) NOT NULL UNIQUE,
    Descricao NVARCHAR(500),
    PaisOrigem NVARCHAR(50),
    AnoFundacao INT,
    LogoUrl NVARCHAR(500),
    SiteOficial NVARCHAR(200),
    Ordem INT DEFAULT 0,
    Ativo BIT DEFAULT 1,
    DataCriacao DATETIME DEFAULT GETDATE(),
    DataAtualizacao DATETIME DEFAULT GETDATE()
);
```

### **15 Grupos Empresariais Cadastrados:**

| Id | Nome | País | Ano Fundação | Fabricantes |
|----|------|------|--------------|-------------|
| 1 | Stellantis | Países Baixos | 2021 | 15 marcas |
| 2 | Volkswagen Group | Alemanha | 1937 | 11 marcas |
| 3 | General Motors | Estados Unidos | 1908 | 4 marcas |
| 4 | Renault-Nissan-Mitsubishi Alliance | França/Japão | 1999 | 6 marcas |
| 5 | Hyundai Motor Group | Coreia do Sul | 1967 | 3 marcas |
| 6 | Ford Motor Company | Estados Unidos | 1903 | 2 marcas |
| 7 | Toyota Motor Corporation | Japão | 1937 | 4 marcas |
| 8 | Honda Motor Company | Japão | 1948 | 2 marcas |
| 9 | BMW Group | Alemanha | 1916 | 3 marcas |
| 10 | Daimler AG (Mercedes-Benz Group) | Alemanha | 1926 | 4 marcas |
| 11 | Geely Holding Group | China | 1986 | 6 marcas |
| 12 | SAIC Motor | China | 1955 | 3 marcas |
| 13 | Tata Motors | Índia | 1945 | 3 marcas |
| 14 | Suzuki Motor Corporation | Japão | 1909 | 1 marca |
| 15 | Mazda Motor Corporation | Japão | 1920 | 1 marca |

### **Modificação: `AIHT_Marcas`**

Adicionada coluna `GrupoEmpresarialId`:
```sql
ALTER TABLE AIHT_Marcas
ADD GrupoEmpresarialId INT NULL,
CONSTRAINT FK_Marcas_GruposEmpresariais 
FOREIGN KEY (GrupoEmpresarialId) REFERENCES AIHT_GruposEmpresariais(Id);
```

---

## 🔧 Stored Procedures Criadas

### **1. `AIHT_sp_ListarGruposEmpresariais`**
Lista todos os grupos empresariais com contagem de fabricantes e modelos.

```sql
EXEC AIHT_sp_ListarGruposEmpresariais;
```

**Retorna:**
```
Id | Nome                              | PaisOrigem      | TotalFabricantes | TotalModelos
---|-----------------------------------|-----------------|------------------|-------------
1  | Stellantis                        | Países Baixos   | 15               | 120
2  | Volkswagen Group                  | Alemanha        | 11               | 85
3  | General Motors                    | Estados Unidos  | 4                | 45
7  | Toyota Motor Corporation          | Japão           | 4                | 60
```

---

### **2. `AIHT_sp_ListarFabricantesPorGrupo`**
Lista fabricantes de um grupo empresarial específico.

```sql
EXEC AIHT_sp_ListarFabricantesPorGrupo @GrupoEmpresarialId = 1; -- Stellantis
```

**Retorna:**
```
Id | Nome        | Pais           | TotalModelos
---|-------------|----------------|-------------
1  | Abarth      | Itália         | 3
2  | Alfa Romeo  | Itália         | 5
3  | Chrysler    | Estados Unidos | 2
4  | Citroën     | França         | 8
5  | Dodge       | Estados Unidos | 4
6  | DS          | França         | 3
7  | Fiat        | Itália         | 12
8  | Jeep        | Estados Unidos | 8
9  | Lancia      | Itália         | 2
10 | Maserati    | Itália         | 4
11 | Opel        | Alemanha       | 6
12 | Peugeot     | França         | 10
13 | Ram         | Estados Unidos | 3
14 | Vauxhall    | Reino Unido    | 4
15 | Leapmotor   | China          | 2
```

---

### **3. `AIHT_sp_ListarModelosPorFabricante`**
Lista modelos de um fabricante específico.

```sql
EXEC AIHT_sp_ListarModelosPorFabricante @FabricanteId = 8; -- Jeep
```

**Retorna:**
```
Id | Nome      | AnoInicio | AnoFim | TipoVeiculo | Periodo
---|-----------|-----------|--------|-------------|-------------
1  | Compass   | 2017      | NULL   | SUV         | 2017 - Atual
2  | Renegade  | 2015      | NULL   | SUV         | 2015 - Atual
3  | Commander | 2022      | NULL   | SUV         | 2022 - Atual
4  | Wrangler  | 1987      | NULL   | SUV         | 1987 - Atual
5  | Grand Cherokee | 1993 | NULL   | SUV         | 1993 - Atual
```

---

### **4. `AIHT_sp_BuscarHierarquiaPorModelo`**
Retorna a hierarquia completa de um modelo (busca reversa).

```sql
EXEC AIHT_sp_BuscarHierarquiaPorModelo @ModeloId = 1; -- Compass
```

**Retorna:**
```
GrupoEmpresarialId | GrupoEmpresarial | FabricanteId | Fabricante | ModeloId | Modelo  | HierarquiaCompleta
-------------------|------------------|--------------|------------|----------|---------|--------------------
1                  | Stellantis       | 8            | Jeep       | 1        | Compass | Stellantis > Jeep > Compass
```

---

### **5. `AIHT_sp_BuscarModelosPorNome`**
Autocomplete para busca de modelos (retorna até 20 resultados).

```sql
EXEC AIHT_sp_BuscarModelosPorNome @TextoBusca = 'Compass';
```

**Retorna:**
```
ModeloId | Modelo  | Fabricante | GrupoEmpresarial | TipoVeiculo | Periodo      | HierarquiaCompleta
---------|---------|------------|------------------|-------------|--------------|--------------------
1        | Compass | Jeep       | Stellantis       | SUV         | 2017 - Atual | Stellantis > Jeep > Compass
```

---

## 💬 Implementação no Chat

### **Fluxo de Seleção Guiada**

```typescript
// 1. Cliente informa o nome
const nome = "João";

// 2. Listar grupos empresariais
const grupos = await db.exec('AIHT_sp_ListarGruposEmpresariais');
// Mostrar: "Qual grupo empresarial? Stellantis (15 marcas), Volkswagen Group (11 marcas)..."

// 3. Cliente seleciona grupo
const grupoId = 1; // Stellantis

// 4. Listar fabricantes do grupo
const fabricantes = await db.exec('AIHT_sp_ListarFabricantesPorGrupo', { grupoId });
// Mostrar: "Qual fabricante? Jeep (8 modelos), Fiat (12 modelos), Peugeot (10 modelos)..."

// 5. Cliente seleciona fabricante
const fabricanteId = 8; // Jeep

// 6. Listar modelos do fabricante
const modelos = await db.exec('AIHT_sp_ListarModelosPorFabricante', { fabricanteId });
// Mostrar: "Qual modelo? Compass, Renegade, Commander, Wrangler..."

// 7. Cliente seleciona modelo
const modeloId = 1; // Compass

// 8. Confirmar hierarquia
const hierarquia = await db.exec('AIHT_sp_BuscarHierarquiaPorModelo', { modeloId });
// "Perfeito! Você possui um Jeep Compass do grupo Stellantis."

// 9. Buscar peças compatíveis
const pecas = await db.exec('AIHT_sp_BuscarPecasPorVeiculo', { modeloId });
```

---

## 🎨 Exemplo de UI no Chat

```
🤖 AutoParts AI:
Olá João! Para te ajudar melhor, vamos identificar seu veículo.
Qual grupo empresarial?

[Botão: 🏢 Stellantis (15 marcas)]
[Botão: 🏢 Volkswagen Group (11 marcas)]  
[Botão: 🏢 General Motors (4 marcas)]
[Botão: 🏢 Toyota Motor Corporation (4 marcas)]
[Link: Ver todos os grupos...]

---

👤 João: [Clica em Stellantis]

---

🤖 AutoParts AI:
Ótimo! O grupo Stellantis possui 15 fabricantes.
Qual é o fabricante do seu veículo?

[Botão: Jeep (8 modelos)]
[Botão: Fiat (12 modelos)]
[Botão: Peugeot (10 modelos)]
[Botão: Citroën (8 modelos)]
[Botão: Dodge (4 modelos)]
[Link: Ver todos os fabricantes Stellantis...]

---

👤 João: [Clica em Jeep]

---

🤖 AutoParts AI:
Qual modelo de Jeep você possui?

[Botão: Compass (2017 - Atual)]
[Botão: Renegade (2015 - Atual)]
[Botão: Commander (2022 - Atual)]
[Botão: Wrangler (1987 - Atual)]
[Botão: Grand Cherokee (1993 - Atual)]

---

👤 João: [Clica em Compass]

---

🤖 AutoParts AI:
Perfeito, João! ✅

📋 Seu veículo:
• Grupo: Stellantis
• Fabricante: Jeep
• Modelo: Compass (SUV)
• Período: 2017 - Atual

Agora posso te mostrar peças compatíveis com seu Jeep Compass.
Qual categoria te interessa?

[Botão: 🔧 Motor]
[Botão: 🛞 Suspensão]
[Botão: 🚦 Freios]
[Botão: ⚡ Elétrica]
[Botão: 🎨 Carroceria]
[Botão: 🔍 Buscar peça específica]
```

---

## ✅ Vantagens da Solução

1. **✅ Hierarquia Real**: Reflete a estrutura real da indústria automotiva
2. **✅ Validação Garantida**: Cliente só pode selecionar combinações válidas
3. **✅ Informação Rica**: Mostra contagem de fabricantes e modelos
4. **✅ Flexibilidade**: Suporta busca guiada OU busca direta
5. **✅ Escalável**: Fácil adicionar novos grupos, fabricantes ou modelos
6. **✅ Performance**: Índices otimizados para consultas rápidas
7. **✅ Integridade**: Foreign keys garantem consistência dos dados

---

## 📊 Grupos Empresariais Cadastrados

### **Stellantis** (15 fabricantes)
Abarth, Alfa Romeo, Chrysler, Citroën, Dodge, DS, Fiat, Jeep, Lancia, Maserati, Opel, Peugeot, Ram, Vauxhall, Leapmotor

### **Volkswagen Group** (11 fabricantes)
Volkswagen, Audi, Porsche, SEAT, Škoda, Bentley, Bugatti, Lamborghini, Ducati, MAN, Scania

### **General Motors** (4 fabricantes)
Chevrolet, GMC, Cadillac, Buick

### **Renault-Nissan-Mitsubishi Alliance** (6 fabricantes)
Renault, Nissan, Mitsubishi, Dacia, Lada, Infiniti

### **Hyundai Motor Group** (3 fabricantes)
Hyundai, Kia, Genesis

### **Ford Motor Company** (2 fabricantes)
Ford, Lincoln

### **Toyota Motor Corporation** (4 fabricantes)
Toyota, Lexus, Daihatsu, Hino

### **Honda Motor Company** (2 fabricantes)
Honda, Acura

### **BMW Group** (3 fabricantes)
BMW, Mini, Rolls-Royce

### **Daimler AG** (4 fabricantes)
Mercedes-Benz, Mercedes-AMG, Smart, Maybach

### **Geely Holding Group** (6 fabricantes)
Geely, Volvo, Polestar, Lotus, Lynk & Co, Proton

### **SAIC Motor** (3 fabricantes)
MG, Roewe, Maxus

### **Tata Motors** (3 fabricantes)
Tata, Jaguar, Land Rover

### **Suzuki Motor Corporation** (1 fabricante)
Suzuki

### **Mazda Motor Corporation** (1 fabricante)
Mazda

---

## 🚀 Próximos Passos

1. **Executar o script SQL**: `06_add_grupos_empresariais.sql`
2. **Criar API Routes** no Next.js para consumir as procedures
3. **Atualizar componente de Chat** com seleção em cascata
4. **Adicionar autocomplete** para busca direta de modelos
5. **Implementar cache** para listas de grupos/fabricantes

---

## 🎯 Conclusão

A hierarquia **Grupo Empresarial → Fabricante → Modelo** está implementada e pronta para uso!

**Execute o script `06_add_grupos_empresariais.sql` para ativar!**
