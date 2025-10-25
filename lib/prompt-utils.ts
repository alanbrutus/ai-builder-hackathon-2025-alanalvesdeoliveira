/**
 * Substitui variáveis no formato {{variavel}} por seus valores
 * @param template - String do template com variáveis
 * @param variables - Objeto com os valores das variáveis
 * @returns String com variáveis substituídas
 */
export function replaceVariables(
  template: string,
  variables: Record<string, string | number>
): string {
  let result = template;

  // Substituir cada variável
  Object.entries(variables).forEach(([key, value]) => {
    const regex = new RegExp(`{{\\s*${key}\\s*}}`, 'g');
    result = result.replace(regex, String(value));
  });

  return result;
}

/**
 * Extrai todas as variáveis de um template
 * @param template - String do template
 * @returns Array com nomes das variáveis encontradas
 */
export function extractVariables(template: string): string[] {
  const regex = /{{\\s*([\\w_]+)\\s*}}/g;
  const variables: string[] = [];
  let match;

  while ((match = regex.exec(template)) !== null) {
    if (!variables.includes(match[1])) {
      variables.push(match[1]);
    }
  }

  return variables;
}

/**
 * Valida se todas as variáveis necessárias foram fornecidas
 * @param template - String do template
 * @param variables - Objeto com os valores das variáveis
 * @returns Objeto com resultado da validação
 */
export function validateVariables(
  template: string,
  variables: Record<string, string | number>
): { valid: boolean; missing: string[] } {
  const required = extractVariables(template);
  const provided = Object.keys(variables);
  const missing = required.filter((v) => !provided.includes(v));

  return {
    valid: missing.length === 0,
    missing,
  };
}

/**
 * Busca e processa um prompt do banco de dados
 * @param contexto - Contexto do prompt (atendimento, recomendacao, finalizacao)
 * @param variables - Variáveis para substituir no prompt
 * @returns Prompt processado com variáveis substituídas
 */
export async function getProcessedPrompt(
  contexto: string,
  variables: Record<string, string | number>
): Promise<{ success: boolean; prompt?: string; error?: string }> {
  try {
    const response = await fetch(`/api/prompts/${contexto}`);
    const data = await response.json();

    if (!data.success) {
      return {
        success: false,
        error: data.error || 'Erro ao buscar prompt',
      };
    }

    const promptTemplate = data.data.ConteudoPrompt;

    // Validar variáveis
    const validation = validateVariables(promptTemplate, variables);
    if (!validation.valid) {
      return {
        success: false,
        error: `Variáveis faltando: ${validation.missing.join(', ')}`,
      };
    }

    // Substituir variáveis
    const processedPrompt = replaceVariables(promptTemplate, variables);

    return {
      success: true,
      prompt: processedPrompt,
    };
  } catch (error) {
    console.error('Erro ao processar prompt:', error);
    return {
      success: false,
      error: 'Erro ao processar prompt',
    };
  }
}

/**
 * Exemplo de uso:
 * 
 * const variables = {
 *   nome_cliente: 'João Silva',
 *   grupo_empresarial: 'Stellantis',
 *   fabricante_veiculo: 'Jeep',
 *   modelo_veiculo: 'Compass'
 * };
 * 
 * const result = await getProcessedPrompt('atendimento', variables);
 * if (result.success) {
 *   console.log(result.prompt);
 * }
 */
