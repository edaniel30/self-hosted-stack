-- init-scripts/01-init-pgvector.sql
-- Este archivo se ejecutará automáticamente al crear el contenedor

-- Crear la extensión pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- Verificar que la extensión se instaló correctamente
SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';

-- Crear una tabla de ejemplo con vectores
CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    embedding vector(1536), -- Dimensión común para embeddings de OpenAI
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índice para búsquedas eficientes
CREATE INDEX IF NOT EXISTS documents_embedding_idx 
ON documents USING ivfflat (embedding vector_cosine_ops) 
WITH (lists = 100);

-- Insertar algunos datos de ejemplo con vectores de 1536 dimensiones
-- Generamos vectores de ejemplo con valores aleatorios normalizados
INSERT INTO documents (title, content, embedding) VALUES
(
    'Documento 1', 
    'Contenido del primer documento', 
    (SELECT array_agg(random()::float4)::vector FROM generate_series(1, 1536))
),
(
    'Documento 2', 
    'Contenido del segundo documento', 
    (SELECT array_agg(random()::float4)::vector FROM generate_series(1, 1536))
)
ON CONFLICT DO NOTHING;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'pgvector configurado correctamente con tabla de ejemplo';
END $$;