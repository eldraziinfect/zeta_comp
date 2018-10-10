#include<stdio.h>
#include<stdlib.h>

typedef struct tree 
{	void* valor;
	int num_filhos;
	tree* pai;
	tree* filho_esq;
	tree* filho_mei;
	tree* filho_dir;
	tree* prox;
} tree;



tree* nova_tree ();
/// cria uma árvore nova

tree* cria_nodo (int valor);
/// faz malloc e seta o tipo

void cria_nodo_unario (tree* atual, int tipo, int valor)
/// chama cria_nodo
/// insere o novo nodo no filho esquerdo

void cria_nodo_binario (tree* atual, int tipo, int valor1, int valor2)
/// chama cria_nodo 2x

void cria_nodo_ternario (tree* atual, int tipo, int valor1, int valor2, int valor3)
/// chama cria_nodo 3x

void conecta_prox (tree* atual, tree* pai)
/// conecta no prox do pai 
// útil para o encadeamento de elements

void insere_no_pai (tree* atual, tree* pai, int posicao); // obsoleto
/// kkk

void libera (tree* nodo);
/// dá free na memória que foi alocada
/// deleta os vínculos

void print_debug();
///obrigatória: imprime a árvore.
/// Como saber aonde começa a árvore? acho que um loop indo até o nodo sem pai funciona
// mas tem que começar em algum lugar...

void descompila();
/// obrigatória: desfaz a árvore e refaz o código.
