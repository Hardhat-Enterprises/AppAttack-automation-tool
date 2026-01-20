#!/usr/bin/env python3
"""
AI Context System for AppAttack Toolkit
Indexes documentation from AI_context_docs/ folder and provides context for LLM queries
"""

import os
import chromadb
from sentence_transformers import SentenceTransformer
from pathlib import Path

class AIContextSystem:
    def __init__(self, docs_path="../AI_context_docs", db_path="./ai_context_db"):
        """Initialize AI Context system"""
        print("🔧 Initializing AI Context system...")
        
        self.docs_path = docs_path
        self.db_path = db_path
        
        # Initialize embedding model (runs locally)
        print("📦 Loading embedding model...")
        self.embedder = SentenceTransformer('all-MiniLM-L6-v2')
        
        # Initialize ChromaDB (local storage)
        self.client = chromadb.PersistentClient(path=db_path)
        self.collection = self.client.get_or_create_collection(
            name="appattack_docs",
            metadata={"description": "AppAttack security tool documentation"}
        )
        
        # Check if we need to index documents
        if self.collection.count() == 0:
            print("📚 First time setup: Indexing documentation...")
            self.index_documents()
        else:
            print(f"✅ AI Context database ready! ({self.collection.count()} document chunks loaded)")
    
    def read_file(self, filepath):
        """Read content from a file"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            print(f"⚠️  Error reading {filepath}: {e}")
            return None
    
    def split_into_chunks(self, text, chunk_size=500, overlap=50):
        """
        Split text into overlapping chunks for better context preservation
        
        Args:
            text: Document text to split
            chunk_size: Number of words per chunk
            overlap: Number of words to overlap between chunks
        """
        words = text.split()
        chunks = []
        
        for i in range(0, len(words), chunk_size - overlap):
            chunk = ' '.join(words[i:i + chunk_size])
            if chunk.strip():  # Only add non-empty chunks
                chunks.append(chunk)
        
        return chunks
    
    def index_documents(self):
        """Read all files from AI_context_docs/ and index them"""
        if not os.path.exists(self.docs_path):
            print(f"❌ Error: {self.docs_path} folder not found!")
            print(f"💡 Please create the folder and add your documentation files.")
            return
        
        doc_count = 0
        chunk_count = 0
        
        # Supported file types
        extensions = ['.txt', '.md', '.rst']
        
        for filename in os.listdir(self.docs_path):
            if any(filename.endswith(ext) for ext in extensions):
                filepath = os.path.join(self.docs_path, filename)
                
                # Read file
                content = self.read_file(filepath)
                if not content:
                    continue
                
                # Split into chunks with overlap
                chunks = self.split_into_chunks(content, chunk_size=500, overlap=50)
                
                # Add each chunk to database
                for i, chunk in enumerate(chunks):
                    chunk_id = f"{filename}_chunk_{i}"
                    
                    self.collection.add(
                        documents=[chunk],
                        ids=[chunk_id],
                        metadatas=[{
                            "source": filename,
                            "chunk": i,
                            "total_chunks": len(chunks)
                        }]
                    )
                    chunk_count += 1
                
                doc_count += 1
                print(f"   ✓ {filename} ({len(chunks)} chunks)")
        
        if doc_count == 0:
            print(f"⚠️  No documentation files found in {self.docs_path}")
            print(f"💡 Add .txt or .md files to get started!")
        else:
            print(f"✅ Indexed {doc_count} documents ({chunk_count} chunks total)!")
    
    def reindex(self):
        """Clear database and re-index all documents"""
        print("🔄 Re-indexing documentation...")
        
        # Delete existing collection
        self.client.delete_collection("appattack_docs")
        
        # Recreate collection
        self.collection = self.client.get_or_create_collection(
            name="appattack_docs",
            metadata={"description": "AppAttack security tool documentation"}
        )
        
        # Re-index
        self.index_documents()
    
    def get_context(self, query, n_results=5):
        """
        Search for relevant documentation based on query
        
        Args:
            query: User's question
            n_results: Number of relevant chunks to return
            
        Returns:
            Tuple of (context_string, list_of_sources)
        """
        if self.collection.count() == 0:
            return "No documentation available. Please add files to AI_context_docs/ folder.", []
        
        # Query the database
        results = self.collection.query(
            query_texts=[query],
            n_results=min(n_results, self.collection.count())
        )
        
        # Extract documents and sources
        documents = results['documents'][0] if results['documents'] else []
        metadatas = results['metadatas'][0] if results['metadatas'] else []
        distances = results['distances'][0] if results['distances'] else []
        
        # Filter out low-relevance results (distance > 1.0 means not very relevant)
        filtered_docs = []
        filtered_sources = []
        
        for doc, meta, dist in zip(documents, metadatas, distances):
            if dist < 1.2:  # Relevance threshold
                filtered_docs.append(doc)
                filtered_sources.append(meta['source'])
        
        if not filtered_docs:
            return "No highly relevant documentation found for this query.", []
        
        # Combine documents into context
        context = "\n\n---\n\n".join(filtered_docs)
        
        # Extract unique sources
        sources = list(set(filtered_sources))
        
        return context, sources
    
    def query(self, user_question, n_results=5):
        """
        Get context and prepare prompt for LLM
        
        Args:
            user_question: The user's question
            n_results: Number of document chunks to retrieve
            
        Returns:
            Tuple of (augmented_prompt, sources)
        """
        print(f"\n🔍 Searching documentation for: '{user_question}'")
        
        # Get relevant context
        context, sources = self.get_context(user_question, n_results)
        
        if sources:
            print(f"📄 Found relevant info in: {', '.join(sources)}")
        else:
            print("⚠️  No relevant documentation found.")
        
        # Build augmented prompt
        augmented_prompt = f"""You are a cybersecurity expert assistant for the AppAttack Toolkit.

Based on the following documentation:

{context}

Question: {user_question}

Please provide a detailed, accurate answer based on the documentation above. If the documentation doesn't contain enough information to fully answer the question, acknowledge this and provide what information is available. Include specific commands, flags, or examples when relevant."""
        
        return augmented_prompt, sources
    
    def list_indexed_files(self):
        """List all files currently indexed in the AI Context system"""
        if self.collection.count() == 0:
            print("No files indexed yet.")
            return
        
        # Get all metadata
        all_data = self.collection.get()
        sources = set()
        
        for meta in all_data['metadatas']:
            sources.add(meta['source'])
        
        print(f"\n📚 Indexed files ({len(sources)} total):")
        for source in sorted(sources):
            print(f"   • {source}")

# Command-line interface
if __name__ == "__main__":
    import sys
    
    # Initialize AI Context
    ai_context = AIContextSystem()
    
    # Handle command-line arguments
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "--list":
            ai_context.list_indexed_files()
        
        elif command == "--reindex":
            ai_context.reindex()
        
        elif command == "--query":
            if len(sys.argv) > 2:
                question = ' '.join(sys.argv[2:])
                prompt, sources = ai_context.query(question, n_results=3)
                print("\n" + "="*50)
                print("CONTEXT FOR AI:")
                print("="*50)
                print(prompt)
            else:
                print("Error: Please provide a question after --query")
                print("Example: python3 ai_context_system.py --query 'How do I use nmap?'")
        
        elif command == "--help":
            print("AI Context System - Usage:")
            print("")
            print("  --list              List all indexed documentation files")
            print("  --reindex           Re-index all documentation files")
            print("  --query <question>  Get AI context for a question")
            print("  --help              Show this help message")
            print("")
            print("Examples:")
            print("  python3 ai_context_system.py --list")
            print("  python3 ai_context_system.py --query 'How to use nmap for port scanning?'")
        
        else:
            print(f"Unknown command: {command}")
            print("Use --help to see available commands")
    
    else:
        # No arguments - run test mode
        print("=== Testing AI Context System ===\n")
        
        ai_context.list_indexed_files()
        
        test_question = "How do I use nmap for service detection?"
        prompt, sources = ai_context.query(test_question, n_results=3)
        
        print("\n" + "="*50)
        print("GENERATED PROMPT FOR LLM:")
        print("="*50)
        print(prompt)
        
        print("\n" + "="*50)
        print("USAGE TIPS:")
        print("="*50)
        print("• Add .txt or .md files to AI_context_docs/ folder")
        print("• Run: python3 ai_context_system.py --reindex")
        print("• Query: python3 ai_context_system.py --query 'your question'")
        print("• Use --help for all commands")
