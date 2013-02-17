#include <stdio.h>
const char *variables [] ={
  "const_9",
  "const_1",
  "const_2",
  "const_3",
  "counter",
  "tmp_var",
  "X0Y0NewCell",
  "X0Y0Cell",
  "X0Y1NewCell",
  "X0Y1Cell", 
  "X0Y2NewCell",
  "X0Y2Cell",
  "X0Y3NewCell",
  "X0Y3Cell",
  "X0Y4NewCell",
  "X0Y4Cell",
  "X1Y0NewCell",
  "X1Y0Cell",
  "X1Y1NewCell",
  "X1Y1Cell",
  "X1Y2NewCell",
  "X1Y2Cell",
  "X1Y3NewCell",
  "X1Y3Cell",
  "X1Y4NewCell",
  "X1Y4Cell",
  "X2Y0NewCell",
  "X2Y0Cell",
  "X2Y1NewCell",
  "X2Y1Cell",
  "X2Y2NewCell",
  "X2Y2Cell",
  "X2Y3NewCell",
  "X2Y3Cell",
  "X2Y4NewCell",
  "X2Y4Cell",
  "X3Y0NewCell",
  "X3Y0Cell",
  "X3Y1NewCell",
  "X3Y1Cell",
  "X3Y2NewCell",
  "X3Y2Cell",
  "X3Y3NewCell",
  "X3Y3Cell",
  "X3Y4NewCell",
  "X3Y4Cell",
  "X4Y0NewCell",
  "X4Y0Cell",
  "X4Y1NewCell",
  "X4Y1Cell",
  "X4Y2NewCell",
  "X4Y2Cell",
  "X4Y3NewCell",
  "X4Y3Cell",
  "X4Y4NewCell",
  "X4Y4Cell"
};
long first_var = 0x8000008;
long last_var  = 0x8037008;
const char begin[] = "[CPU0 WR]: LIN";
const char begin2[] = "[CPU0 RD]: LIN";
int main(){
  size_t bufsize= 1024;
  char *buf = malloc(bufsize);
long progress_dot = 256*1024*1024;
 long progress = progress_dot;			
 long line =0;

  while(!feof(stdin)){
    unsigned long addr, value, len, read,idx;
    progress -= getline(&buf,&bufsize,stdin);
    if(progress < 0){
      fputc('.',stderr);
      progress = progress_dot;
    }
    if(strncmp(begin,buf,sizeof begin - 1)){
      if(strncmp(begin2,buf,sizeof begin2 - 1))
	continue;
      else
	read = 1;
    }
    else
      read = 0;
    if(strncmp("PHY ",buf + 34,4))
      continue;
    sscanf(buf + 34, "PHY %llX (len=%d, pl=0): %llX",&addr, &len,&value);
    if(addr % 4096 != 8)
      continue;
    if(!line++)
      continue; /*First trace is bs*/
    if(first_var > addr || addr > last_var)
      continue;
    idx = (addr - first_var) >> 12 ;
    if(idx > 55 || idx < 0)
      {
	printf("Damn index calculation\n");
	break;
      }
    if(4 != len){
      printf("Weird length on line %s %X\n",buf,addr);
      continue;
    }
    if(read)
      printf("R %s %llX\n",variables[idx],value);
    else
      printf("W %s %llX\n",variables[idx],value);
  }
  
}


