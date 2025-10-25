import { NextResponse } from 'next/server';

export async function GET() {
  const apiKey = process.env.GEMINI_API_KEY;
  
  return NextResponse.json({
    hasApiKey: !!apiKey,
    keyLength: apiKey ? apiKey.length : 0,
    keyPreview: apiKey ? `${apiKey.substring(0, 10)}...` : 'não encontrada',
    allEnvKeys: Object.keys(process.env).filter(k => k.includes('GEMINI'))
  });
}
