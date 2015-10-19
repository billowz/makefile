/*
 * test.c
 *
 *  Created on: 18 Oct 2015
 *      Author: cmp
 */
#include "../inc/test.h"
#include "../inc/test2.h"
#include <stdio.h>
#include <sys/time.h>

float getTimeuse(struct timeval *start){
    struct timeval end;
    int timeuse;
    gettimeofday(&end, NULL);
    timeuse = 1000000 * ( end.tv_sec - start->tv_sec ) + end.tv_usec - start->tv_usec;
    return (float)timeuse/1000;
}
int main(){
	struct timeval start;
    gettimeofday(&start, NULL );
	int i=0;
	long ret = 0;
	#pragma simd
	#pragma vector aligned
	for(i=0; i<100000000; i++){
		ret++;
	}
    printf("each %d times use %.6fms => %lld\n", i, getTimeuse(&start), ret);
	return 0;
}
