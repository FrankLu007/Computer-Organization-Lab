#include <iostream>
#include <stdio.h>
#include <math.h>

/**
* direct_mapped_cache_lru usage:
* copy "LU.txt" and "RADIX.txt" to the same folder as the executable
* then run this program
*/
using namespace std;

struct cache_content{
	bool v;
	unsigned int  tag;
	int age; // age is 1 ~ associativity
	// most recently used: age = 1
	// least recently used: age = associativity
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

void simulate(int cache_size, int block_size, int associativity, const char* filename){
	unsigned int tag,index,x;

	int offset_bit = (int) log2_int(block_size);
	int index_bit = (int) log2_int(cache_size/block_size);
	int assoc_bit = (int) log2_int(associativity);
	int line= cache_size>>(offset_bit);

	cache_content *cache =new cache_content[line];
	cout<<"cache line:"<<line<<endl;

	for(int j=0;j<line;j++){
		cache[j].v=false;
		cache[j].age = (j&(associativity-1))+1; // set age to 1, 2, 3, ... , associativity
	}

  FILE * fp=fopen(filename,"r");					//read file

  int miss=0, total = 0;
	while(fscanf(fp,"%x",&x)!=EOF){
		//cout<<hex<<x<<" ";
		index=(x>>offset_bit)&(line-1);
		tag=x>>(index_bit+offset_bit);

		tag = (tag<<assoc_bit) | (index & (associativity-1)); // add index in associativity group
        index = index & ~(associativity-1); // get associativity group
		bool hit = false;
		for (int i=0; i<associativity && !hit; i++) { // find cache
            if(cache[index+i].v && cache[index+i].tag==tag){
                cache[index+i].v=true; 			//hit
                //cout<<"hit"<<std::endl;
                hit = true;
                int myage = cache[index+i].age;
                for (int j=0;j<associativity;j++){ // update cache age
                    if (cache[index+j].age < myage) {
                        cache[index+j].age++;
                    }
                }
                cache[index+i].age = 1;
            }
		}
		if(!hit) {
            int lru;
            for (lru=0; lru<associativity; lru++){ // find least recently used cache
                if (cache[index+lru].age == associativity) {
                    break;
                }
            }
            cache[index+lru].v=true;			//miss
            cache[index+lru].tag=tag;
            //cout<<"miss"<<std::endl;
            miss++;

            cache[index+lru].age = 0;
            for (int i=0;i<associativity;i++){ // update cache age
                cache[index+i].age++;
            }
        }
		total++;
	}
	std::cout << "miss rate: " << (float)miss/total << std::endl;
	fclose(fp);

	delete [] cache;
}

void simulate_file(const char *filename){
    int cache_size[6] = {1*K, 2*K, 4*K, 8*K, 16*K, 32*K};
    int block_size[1] = {32};
    int assoc[4] = {1, 2, 4, 8};
    // simulate each cache size
    std::cout << "Simulating " << filename << "\n";
	for (int i=0; i<6; i++) {
        for(int j=0; j<4; j++){
            std::cout << "cache size=" << cache_size[i] << ", block size=" << block_size[0] << ", associativity=" << assoc[j] << std::endl;
            simulate(cache_size[i], block_size[0], assoc[j], filename);
        }
	}
	std::cout << std::endl;
}

int main() {
    simulate_file("LU.txt");
    simulate_file("RADIX.txt");
}
