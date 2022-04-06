Rainbow
=======

Yet another rainbow table generation and search tool software.

Rainbow tables
--------------

We consider the problem of finding back a value from its hash (in the
current implementation, MD5, SHA1, SHA256 and SM3). Formally, we want to perform a preimage
attack. Since hash functions are designed to be resistant to preimage
attacks, we are often reduced to brute forcing: consider every single
possible value, hash it and match it against the target hash. This is
guaranteed to work but can take tremendeous amounts of time.

For feasible targets, we can speed up the process by storing the result
of all these hashes in a (sorted) table. That way, whenever a new hash
comes in, we simply have to look it up in the table. However, lookup
tables tend to be huge and impractical.

    C -> 12b2
    B -> 3e4f
    A -> 467f
    D -> 8801

Here, the hash 0e4f would be easily mapped to the value B.

The root idea of rainbow tables is to find a middle point between brute
force cracking and lookup tables. Instead of storing every value/hash
couples, they are grouped in "chains" each identified by one initial
value and one final hash. Basically, the hash of the initial value
is mapped to a new value, which is hashed in turn, mapped, and so on,
a fixed number of times, until a final hash.

    A -> 467f -> D -> 8801 -> H -> 6939
    B -> 3e4f -> C -> 12b2 -> A -> 3e4f

In the example above, we choose to map hashes to values by taking the
first character of the hash and taking the corresponding letter of
the alphabet (e.g. `7 -> G`). Now, notice that we can freely choose the
initial values but the middle are already determined; some may not appear
(e.g. E) and some may appear twice (e.g. A). However, we do control the
mapping function so that we can optimize the repartition.

In this case, all that is actually stored is:

    A --> 6939
    B --> 3e4f

Now, if we are given some hash target (e.g. 12b2), we apply the map-hash
process until we find a matching value in the table and consider the chain
it belongs to. We then follow the chain until the value. In the example:

    12b2 -> A -> 3e4f

From the rainbow table, 3e4f corresponds to the chain beginning with B:

    B -> 3e4f -> C

The mapping operation used in rainbow tables is called reduction.

Parameters
----------

From what we have done, when manipulating a rainbow table, we have to
consider the following parameters:

* key space: this is the set of all the values we may have to consider (e.g. 8 characters words)
* chain length: this is the number of time we proceed to reduction-hashing from an initial value
* table size: the number of chains in the table
* reduction seed: to better cover the key space while avoiding duplicates,
  it is best to generate several rainbow tables with different reduction
  functions; the reduction seed is a number which basically sets a
  reduction function
* part number: rainbow tables are way smaller than lookup tables but
  still take quite some space; some systems do not handle large files
  properly so it is usual to split rainbow tables in several parts

The keyspace is usually defined by the number and the set of characters
(charset) that makes a value. The charset is hardcoded in this program
but can be changed easily.

Compile
--------
system: Linux
use the paramter "HASH" to control the compile process when use "make",just like below:

>make destroy
>
>make HASH=-D_SM3 //compile the sm3 gen crack program
>
> //make HASH=-D_MD5 //compile the sm3 gen crack program
>
>

Examples
--------

Generate a single (weak) rainbow table for 6 character words:

    $ ./rtgen 6 0 2500 500000 1 0 alpha4.rt

Attempt to crack a value with this table:

    # for MD5
    $ echo -n 6c02ec | md5sum                                      
    750f4b11bbd880f9fb9bcd0c24b7b473  -
    $ ./rtcrack -x $(echo -n 6c02ec | md5sum) alpha4.rt
    750f4b11bbd880f9fb9bcd0c24b7b473 6c02ec

    # for SHA1
    $ echo -n gPO100 | sha1sum                                      
    23a171799896ec207e64317d50d5d228b20ae15f  -
    $ ./rtcrack -x $(echo -n gPO100 | sha1sum) alpha4.rt
    c600f900c711b0fe548b922c157f9dc1864ff06b gPO100

    # for SHA256
    $ echo -n j70000 | sha256sum                                      
    54b112f3a7214022afe20797c42983f9fb0d87ee4c6658791f8bc001a79653f8  -
    $ ./rtcrack -x $(echo -n j70000 | sha256sum ) alpha4.rt
    54b112f3a7214022afe20797c42983f9fb0d87ee4c6658791f8bc001a79653f8 j70000
    
    # for SHA1
    $ echo -n gPO100 | sha1sum                                      
    23a171799896ec207e64317d50d5d228b20ae15f  -
    $ ./rtcrack -x $(echo -n gPO100 | sha1sum) alpha4.rt
    c600f900c711b0fe548b922c157f9dc1864ff06b gPO100
    
    # for SHA256
    $ echo -n j70000 | sha256sum                                      
    54b112f3a7214022afe20797c42983f9fb0d87ee4c6658791f8bc001a79653f8  -
    $ ./rtcrack -x $(echo -n j70000 | sha256sum ) alpha4.rt
    54b112f3a7214022afe20797c42983f9fb0d87ee4c6658791f8bc001a79653f8 j70000
    
    # for SM3
    $ echo -n mm8200 | python3 sm3/sm3.py
    c1bf0d86d772d904c0e6268760cac9b0256d09fb60e44360ef1c996c1a4d0389
    $ ./rtcrack -x $(echo -n mm8200 | python3 sm3/sm3.py) alpha4.rt
    c1bf0d86d772d904c0e6268760cac9b0256d09fb60e44360ef1c996c1a4d0389 mm8200
    $ ./rtcrack -x $(echo -n 0oz100 | python3 sm3/sm3.py) rt/alnum_6_1000_1000000_1/*
    425edaf85aae854ffe4c1269a36206cfa68d5dc363966807c6127c0b1c826d3a 0oz100




You can test how efficient a table is by cracking for random values:

    $ ./rtcrack -r 1000 alpha4.rt 
    204 / 1000

A bash script makes it easy to generate rainbow tables for several
reduction seeds and in several parts:

    $ ./gen.sh 6 1000 1000000 0 10 1
    $ ./rtcrack -r 1000 rt/alnum_6_1000_1000000_1/*
    992 / 1000

Add Hash Function
---
To add a hash function(eg. sha1) to this project, you should have the sha1.h and sha1.c files.
1. in the sha1.h, you should define a micro named "SHA1_DIGEST_LENGTH", the value of it is the length of the hash function output(by bytes), for sha1 it is 20(sha1 output is 160 bits, 160/8=20bytes).
At the same time, you should define a function, which is fit to the interface below:

   
   > typedef void HASHptr(uint8_t* dst, const uint8_t* src, uint64_t slen);//in the hashselect.h file
   >  //you can do like this:
   >  void SHA1(uint8_t *dst, const uint8_t* src, uint64_t slen); 
2. in the sha1.c, implement correct
3. in the hashselect.h, you should include the "sha1.h", and add below:
    
    > #elif _SHA1 //a macro named "_SHA1"
    > #define DIGEST_LENGTH SHA1_DIGEST_LENGTH //in sha1.h
    > static HASHptr *my_hash = &SHA1;    // in sha1.h  , and the "SHA1" is your implement
    
4. finally, you should add the sha1.o in Makefile, to make sure you can compile it correctly.
to complie it ,you can do like this:
   
   > make HASH=-D_SHA1 


Licence
-------

This program is distributed under the GPL licence (see
[LICENCE.md](LICENCE.md) file). The credits for markdown formatting goes
to https://github.com/IQAndreas/markdown-licenses
