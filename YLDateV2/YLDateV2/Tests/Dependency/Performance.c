//
//  Performance.c
//  Calendar
//
//  Created by Jasonluo on 12/9/11.
//  Copyright (c) 2011 YouLoft.Com. All rights reserved.
//

#include <stdio.h>
#include "Performance.h"

int indexOfElement(const int* array,int element,int length) {
    int low,high,mid;
    low = 0;
    high = length-1;
    while (low <= high) {
        mid = (low +high)/2;
        if(element > array[mid]){
            low = mid+1;
        }
        else if (element < array[mid]){
            high = mid-1;
        }
        else {
            return mid;
        }
    }
    return -1;
}
void bubleSort(int* array,int length,bool dec) {
    int i,j,tmp;
    for(j=0;j<length;j++) { 
        for (i=0;i<length-j-1;i++) {
            if (dec) {
                if (array[i]<array[i+1]) { 
                    tmp=array[i]; 
                    array[i]=array[i+1]; 
                    array[i+1]=tmp;
                } 
            }
            else {
                if (array[i]>array[i+1]) { 
                    tmp=array[i]; 
                    array[i]=array[i+1]; 
                    array[i+1]=tmp;
                } 
            }
        }
    } 
}
