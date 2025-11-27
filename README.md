# App Financeiro Pessoal (MVP)

**Versão:** 1.0 - Produto Mínimo Viável  
**Data:** 23 de Novembro de 2025

Aplicativo Flutter para controle financeiro pessoal completo, permitindo o gerenciamento de receitas e despesas com análise em tempo real.

## 📋 Visão Geral

O App Financeiro Pessoal é uma ferramenta mobile projetada para ajudar o utilizador a monitorizar e analisar as suas finanças mensais de forma simples e em tempo real.

### 🎯 Objetivos Chave

- **Controlo**: Fornece uma visão clara de receitas e despesas mensais
- **Análise**: Calcula automaticamente métricas como Lucro Líquido e Margem de Lucro
- **Persistência**: Dados guardados de forma segura e acessível em tempo real
- **Simplicidade**: Interface limpa e intuitiva (Mobile-First)

## 🎁 Recursos Implementados

### Requisitos Funcionais (DRP)

- ✅ **FR01**: Registro de Transações (Receita ou Despesa)
- ✅ **FR02**: Seleção de Período (mês e ano)
- ✅ **FR03**: Cálculo de Receita Total
- ✅ **FR04**: Cálculo de Despesa Total
- ✅ **FR05**: Cálculo de Lucro Líquido
- ✅ **FR06**: Cálculo de Margem de Lucro
- ✅ **FR07**: Listagem Detalhada por Data
- ✅ **FR08**: Exclusão de Transação
- ✅ **FR09**: Atualização em Tempo Real (Provider)

### Histórias de Utilizador

- ✅ **US01**: Inserir despesas e atualizar total automaticamente
- ✅ **US02**: Inserir receitas e atualizar saldo positivo
- ✅ **US03**: Ver dados de um mês específico
- ✅ **US04**: Lucro Líquido com cores (verde/vermelho/cinza)
- ✅ **US05**: Remover transações incorretas

## 🚀 Como executar

```bash
# Instalar dependências
flutter pub get

# Executar aplicativo
flutter run
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                      # App principal com Provider
├── routes/
│   └── app_routes.dart           # Sistema de rotas (GoRouter)
├── screens/
│   ├── home_screen.dart          # Tela inicial com métricas
│   ├── add_expense_screen.dart   # Adicionar/Editar transações
│   ├── expense_list_screen.dart  # Lista de transações
│   └── reports_screen.dart       # Relatórios e gráficos
├── models/
│   ├── expense.dart              # Modelo Transaction
│   └── category.dart             # Modelo Category
├── providers/
│   └── expense_provider.dart     # Gerenciamento de estado
└── widgets/
    └── expense_card.dart         # Card de transação
```

## 💡 Funcionalidades Detalhadas

### 1. Tela Principal (Dashboard)
- Card de Lucro Líquido com cores dinâmicas
- Indicadores de Receitas e Despesas
- Margem de Lucro em porcentagem
- Transações recentes

### 2. Adicionar Transação
- Seletor de tipo: Receita ou Despesa
- Campos: Título, Valor, Categoria, Data, Descrição
- Validação de formulário
- Edição e exclusão de transações

### 3. Lista de Transações
- Filtros por tipo (Receita/Despesa/Todos)
- Filtros por categoria
- Agrupamento por data
- Totais diários com cores dinâmicas
- Acesso rápido para edição

### 4. Relatórios
- Seleção de mês/ano
- Métricas financeiras completas:
  - Receitas totais
  - Despesas totais
  - Lucro líquido
  - Margem de lucro (%)
- Gráfico de pizza (despesas por categoria)
- Detalhamento por categoria com percentuais

## 🛠 Stack Tecnológica

- **Framework**: Flutter 3.0+
- **Linguagem**: Dart
- **Gerenciamento de Estado**: Provider
- **Navegação**: GoRouter
- **Gráficos**: FL Chart
- **Formatação**: Intl (pt_BR)
- **UI**: Material Design 3

## 📦 Dependências Principais

```yaml
provider: ^6.1.1          # Estado
go_router: ^13.0.0        # Rotas
intl: ^0.19.0             # Formatação
fl_chart: ^0.66.0         # Gráficos
```

## 🎨 Design

- Material Design 3
- Cores dinâmicas baseadas no status financeiro
- Interface responsiva e intuitiva
- Ícones semânticos (↑ receita, ↓ despesa)
- Feedback visual em tempo real

## 👥 Público-Alvo

- Indivíduos que precisam controlar orçamento pessoal
- Pequenos empresários/autónomos
- Quem busca simplicidade sem complexidade de software contabilístico

## 📊 Métricas de Sucesso (KPI)

- Taxa de Registro de Dados: Transações inseridas por semana
- Utilização Mensal: Consultas ao relatório (> 3x/mês)
- Latência de Atualização: Tempo entre adicionar e atualizar dashboard
