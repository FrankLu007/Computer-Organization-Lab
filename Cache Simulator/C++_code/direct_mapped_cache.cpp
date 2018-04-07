#include <iostream>
#include <stdio.h>
#include <math.h>

/**
* direct_mapped_cache usage:
* copy "ICACHE.txt" and "DCACHE.txt" to the same folder as the executable
* then run this program
*/
using namespace std;

struct cache_content{
	bool v;
	unsigned int  tag;
//	unsigned int	data[16];
};

const int K=1024;

// this log2 is not good
double log2( double n )
{
    // log(n)/log(2) is log2.
    return log( n ) / log(double(2));
}
// so I rewrite integer version of log2
int log2_int( unsigned int n )
{
    if (n == 0) return -1; // actually it's negative infinity
    int result = 0;
    // calculate log2 using binary search
    if (n >= 0x10000) {
        result += 16; n>>=16;
    }
    if (n >= 0x100) {
        result += 8; n>>=8;
    }
    if (n >= 0x10) {
        result += 4; n>>=4;
    }
    if (n >= 4) {
        result += 2; n>>=2;
    }
    if (n >= 2) {
        result += 1; n>>=1;
    }
    return result;
}

void simulate(int cache_size, int block_size, const char *filename){
	unsigned int tag,index,x;

	int offset_bit = (int) log2_int(block_size);
	int index_bit = (int) log2_int(cache_size/block_size);
	int line= cache_size>>(offset_bit);

	cache_content *cache =new cache_content[line];
	//cout<<"cache line:"<<line<<endl;

	for(int j=0;j<line;j++)
		cache[j].v=false;

  FILE * fp=fopen(filename,"r");					//read file

  int miss=0, total = 0;
	while(fscanf(fp,"%x",&x)!=EOF){
		//cout<<hex<<x<<" ";
		index=(x>>offset_bit)&(line-1);
		tag=x>>(index_bit+offset_bit);
		if(cache[index].v && cache[index].tag==tag){
			cache[index].v=true; 			//hit
			//cout<<"hit"<<std::endl;
		}
		else{
			cache[index].v=true;			//miss
			cache[index].tag=tag;
			//cout<<"miss"<<std::endl;
			miss++;
		}
		total++;
	}
	std::cout << " miss rate: " << (float)miss/total << std::endl;
	fclose(fp);

	delete [] cache;
}

void simulate_file(const char* name){
    int cache_size[4] = {64, 128, 256, 512};
    int block_size[4] = {4, 8, 16, 32};
    // simulate each cache size
    std::cout<<"simulating file "<<name<<std::endl;
	for (int i=0; i<4; i++) {
        for(int j=0; j<4; j++){
            std::cout << "cache size=" << cache_size[i] << ", block size=" << block_size[j] << std::endl;
            simulate(cache_size[i], block_size[j], name);
        }
	}
	std::cout<<std::endl;
}

int main() {
    simulate_file("ICACHE.txt");
    simulate_file("DCACHE.txt");
    return 0;
}
