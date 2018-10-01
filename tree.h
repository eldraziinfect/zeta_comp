#include<stdio.h>
#include<stdlib.h>

typedef struct tree 
{	void* valor;
	int num_filhos;
	tree* pai;
	tree* filho_esq;
	tree* filho_mei;
	tree* filho_dir;
	tree* next;
} tree;



tree* nova_tree ();
/// cria uma árvore nova

tree* cria_nodo (int tipo);
/// faz malloc e seta o tipo

void insere_nodo (tree* atual, tree* esquerdo, tree* meio, tree* direito );
/// define os valores dos ponteiros e das variáveis de controle
/// nodos com menos filhos passam NULL

void libera (tree* nodo);
/// 


