#include <cmph.h>
#include <string.h>
#include <sys/time.h>

char **gen_keys(unsigned int size){

    char *keyPrefix = "KEY-";
    unsigned int prefixLen = strlen(keyPrefix);
    char **keys = malloc(sizeof(char *) * size);
    unsigned int i = 0;
    for(; i < size; i++){
        keys[i] = malloc(sizeof(char) * prefixLen + sizeof(unsigned int) + 1);
        sprintf(keys[i], "%s%d", keyPrefix, i);
    }
    return keys;
}

void free_keys(char **keys, unsigned int size){
    unsigned int i=0; 
    for(; i < size; i++){
        free(keys[i]);
    }
    free(keys);
}

float getTimeuse(struct timeval *start){
    struct timeval end;
    int timeuse;
    gettimeofday(&end, NULL);
    timeuse = 1000000 * ( end.tv_sec - start->tv_sec ) + end.tv_usec - start->tv_usec;
    return (float)timeuse/1000; 
}

// Create minimal perfect hash function from in-memory vector
int main(int argc, char **argv){ 
    unsigned int size = argc >1 ? atoi(argv[1]): 10;
    char ** vector = gen_keys(size);
    unsigned int i = 0;  
    unsigned int id;
    char *key;
    struct timeval start, start2;
    CMPH_ALGO algo;
    cmph_t *hash;
    FILE *mphf_fd = fopen("temp.mph", "w");

    if(argc>2){
        switch(atoi(argv[2])){
            case 0:
                algo = CMPH_BMZ;
                break;
            case 1:
                algo = CMPH_BMZ8;
                break;
            case 2: 
                algo = CMPH_BRZ;
                break;
            case 3:
                algo = CMPH_FCH;
                break;
            case 4:
                algo = CMPH_BDZ;
                break;
            case 5:
                algo = CMPH_BDZ_PH;
                break;
            case 6:
                algo = CMPH_CHD_PH;
                break;
            case 7:
                algo = CMPH_CHD;
                break;
            case 8:
                algo = CMPH_COUNT;
                break;
            default:
                printf("Invalid Algo");
                return 1;
        }
    }else{
        algo = CMPH_CHD;
    }

    gettimeofday(&start, NULL );

    cmph_io_adapter_t *source = cmph_io_vector_adapter(vector, size);
    
    //Create minimal perfect hash function using the brz algorithm.
    
    gettimeofday(&start2, NULL );

    cmph_config_t *config = cmph_config_new(source);
    cmph_config_set_algo(config, algo);
    cmph_config_set_mphf_fd(config, mphf_fd);
    hash = cmph_new(config);
    printf("cmph_new[%d] use %.3f ms\n", size, getTimeuse(&start2));

    cmph_config_destroy(config);

    gettimeofday(&start2, NULL );
    cmph_dump(hash, mphf_fd); 
    printf("cmph_dump[%d] use %.3f ms\n", size, getTimeuse(&start2));
    gettimeofday(&start2, NULL );

    printf("Build Hash[%d] use %.3f ms\n", size, getTimeuse(&start));

    //cmph_destroy(hash); 
    //fclose(mphf_fd);
    //printf("Desctory Hash[%d] use %.3f ms\n", size, getTimeuse(&start2));

    //gettimeofday(&start, NULL );
    
    //Find key
    //mphf_fd = fopen("temp.mph", "r");
    //hash = cmph_load(mphf_fd);

    //printf("Load CMPH from disk use %.3f ms\n", getTimeuse(&start));

    gettimeofday(&start, NULL );
    for (; i < size; i++) {
        key = vector[i];
        id = cmph_search(hash, key, (cmph_uint32)strlen(key));
        //fprintf(stderr, "key:%s -- hash:%u\n", key, id);
    }

    printf("Find CMPH[%d] %d times use %.3f ms\n", size, size, getTimeuse(&start));
    printf("Average key find time : %.6f ms\n", getTimeuse(&start)/size);

    gettimeofday(&start, NULL );

    //Destroy hash
    cmph_destroy(hash);
    cmph_io_vector_adapter_destroy(source);   
    fclose(mphf_fd);

    printf("Destory CMPH use %.3f ms\n", getTimeuse(&start));

    return 0;
}
