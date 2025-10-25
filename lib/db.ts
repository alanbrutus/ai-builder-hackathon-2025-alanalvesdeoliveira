import sql from 'mssql';

const config: sql.config = {
  server: 'localhost\\ALYASQLEXPRESS',
  database: 'AI_Builder_Hackthon',
  user: 'AI_Hackthon',
  password: '41@H4ckth0n',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true,
    instanceName: 'ALYASQLEXPRESS',
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
  connectionTimeout: 30000,
  requestTimeout: 30000,
};

let pool: sql.ConnectionPool | null = null;

export async function getConnection(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config);
  }
  return pool;
}

export async function executeStoredProcedure<T = any>(
  procedureName: string,
  params?: Record<string, any>
): Promise<T[]> {
  try {
    const connection = await getConnection();
    const request = connection.request();

    // Adicionar parâmetros se existirem
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        request.input(key, value);
      });
    }

    const result = await request.execute(procedureName);
    return result.recordset as T[];
  } catch (error) {
    console.error('Erro ao executar stored procedure:', error);
    throw error;
  }
}

export async function executeQuery<T = any>(query: string): Promise<T[]> {
  try {
    const connection = await getConnection();
    const result = await connection.request().query(query);
    return result.recordset as T[];
  } catch (error) {
    console.error('Erro ao executar query:', error);
    throw error;
  }
}

export { sql };
