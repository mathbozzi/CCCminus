
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tables.h"

// Strings Table
// ----------------------------------------------------------------------------

#define STRING_MAX_SIZE 128
#define STRINGS_TABLE_MAX_SIZE 100

struct str_table {
    char t[STRINGS_TABLE_MAX_SIZE][STRING_MAX_SIZE];
    int size;
};

StrTable* create_str_table() {
    StrTable *st = malloc(sizeof * st);
    st->size = 0;
    return st;
}

int add_string(StrTable* st, char* s) {
    for (int i = 0; i < st->size; i++) {
        if (strcmp(st->t[i], s) == 0) {
            return i;
        }
    }
    strcpy(st->t[st->size], s);
    int idx_added = st->size;
    st->size++;
    return idx_added;
}

char* get_string(StrTable* st, int i) {
    return st->t[i];
}

void print_str_table(StrTable* st) {
    printf("Strings table:\n");
    for (int i = 0; i < st->size; i++) {
        printf("Entry %d -- %s\n", i, get_string(st, i));
    }
}

void free_str_table(StrTable* st) {
    free(st);
}

// Variables Table
// ----------------------------------------------------------------------------

#define VARIABLE_MAX_SIZE 128
#define VARIABLES_TABLE_MAX_SIZE 100

typedef struct {
  char name[VARIABLE_MAX_SIZE];  
  int line;  
  int escopo;    
  int aridade;    
} Entry;

struct var_table {
    Entry t[VARIABLES_TABLE_MAX_SIZE];
    int size;
};

VarTable* create_var_table() {
    VarTable *vt = malloc(sizeof * vt);
    vt->size = 0;
    return vt;
}

int lookup_var(VarTable* vt, char* s, int escopo) { //add escopo
    for (int i = 0; i < vt->size; i++) {
        if (vt->t[i].escopo == escopo && strcmp(vt->t[i].name, s) == 0)  {
            return i;
        }
    }
    return -1;
}

int add_var(VarTable* vt, char* s, int line, int escopo) {
    strcpy(vt->t[vt->size].name, s);
    vt->t[vt->size].line = line;
    vt->t[vt->size].escopo = escopo;
    int idx_added = vt->size;
    vt->size++;
    return idx_added;
}

char* get_name(VarTable* vt, int i) {
    return vt->t[i].name;
}

int get_line(VarTable* vt, int i) {
    return vt->t[i].line;
}

void print_var_table(VarTable* vt) {
    printf("Variables table:\n");
    for (int i = 0; i < vt->size; i++) {
         printf("Entry %d -- name: %s, line: %d, scope: %d\n", i,
                get_name(vt, i), get_line(vt, i), get_escopo(vt, i));
    }
}

void free_var_table(VarTable* vt) {
    free(vt);
}

//--------------mudancas-----------------------------------------------

int get_aridade(VarTable* vt, int i) {
    return vt->t[i].aridade;
}

int get_escopo(VarTable* vt, int i) {
    return vt->t[i].escopo;
}


int lookup_fun(VarTable* vt, char* s) {
    for (int i = 0; i < vt->size; i++) {
        if (strcmp(vt->t[i].name, s) == 0)  {
            return i;
        }
    }
    return -1;
}

void print_fun_table(VarTable* vt) {
    printf("Function table:\n");
    for (int i = 0; i < vt->size; i++) {
         printf("Entry %d -- name: %s, line: %d, arity: %d\n", i,
                get_name(vt, i), get_line(vt, i), get_aridade(vt, i));
    }
}

char* type2str(IdType type) {
    switch(type) {
        case SVAR: return "SVAR";
        case CVAR: return "CVAR";
        case FUNC: return "FUNC";
        default: return "wtf";
    }
}

int add_fun(VarTable* vt, char* s, int line, int aridade) {
    strcpy(vt->t[vt->size].name, s);
    vt->t[vt->size].aridade = aridade;
    vt->t[vt->size].line = line;
    int idx_added = vt->size;
    vt->size++;
    return idx_added;
}