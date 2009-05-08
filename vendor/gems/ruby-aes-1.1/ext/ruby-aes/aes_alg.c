#include "ruby.h"

/*
    This file is a part of ruby-aes <http://rubyforge.org/projects/ruby-aes>
    Written by Alex Boussinet <alex.boussinet@gmail.com>

    This version is derived from the Optimised ANSI C code
    Authors of C version:
        Vincent Rijmen <vincent.rijmen@esat.kuleuven.ac.be>
        Antoon Bosselaers <antoon.bosselaers@esat.kuleuven.ac.be>
        Paulo Barreto <paulo.barreto@terra.com.br>
    Loop unroll optimization

Added:
    Table look up improvements based on "Table Unroll Optimized 2" variation
*/

#ifdef DEBUG
#define TRACE()  fprintf(stderr, "> %s:%d:%s\n", __FILE__, __LINE__, __FUNCTION__)
#else
#define TRACE()
#endif

#define MODE_ECB    0
#define MODE_CBC    1
#define MODE_CFB    2
#define MODE_OFB    3

typedef unsigned int    uint;
typedef unsigned char   uchar;

#include "aes_cons.h"

#define SWAP(n) \
    (((n & 0x000000ff) << 24) | ((n & 0x0000ff00) <<  8) | \
     ((n & 0x00ff0000) >>  8) | ((n & 0xff000000) >> 24))

typedef struct {
    uchar   *state;
    uchar   *state2;
    uchar   *iv;
    uchar   *key;
    uint    *ek;    /* encryption key */
    uint    *dk;    /* decryption key */
    int     mode;
    int     kl;
    int     nb;
    int     nr;
    int     nk;
} AES;

static VALUE   rb_cAes;

#define BLOCK_SIZE  16

#define FREE(ptr) freeset((void**)&ptr)
void
freeset(void **ptr)
{
    free(*ptr);
    *ptr = NULL;
}

void
aes_encrypt(AES *data, uchar *pt, uchar *output)
{
    int j;

    /* map byte array block to cipher state and add initial round key: */
    uint s0 = (pt[ 0] << 24 | pt[ 1] << 16 | pt[ 2] << 8 | pt[ 3]) ^ data->ek[0];
    uint s1 = (pt[ 4] << 24 | pt[ 5] << 16 | pt[ 6] << 8 | pt[ 7]) ^ data->ek[1];
    uint s2 = (pt[ 8] << 24 | pt[ 9] << 16 | pt[10] << 8 | pt[11]) ^ data->ek[2];
    uint s3 = (pt[12] << 24 | pt[13] << 16 | pt[14] << 8 | pt[15]) ^ data->ek[3];
    /* round 1: */
    uint t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ data->ek[ 4];
    uint t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ data->ek[ 5];
    uint t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ data->ek[ 6];
    uint t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ data->ek[ 7];
    /* round 2: */
    s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ data->ek[ 8];
    s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ data->ek[ 9];
    s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ data->ek[10];
    s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ data->ek[11];
    /* round 3: */
    t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ data->ek[12];
    t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ data->ek[13];
    t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ data->ek[14];
    t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ data->ek[15];
    /* round 4: */
    s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ data->ek[16];
    s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ data->ek[17];
    s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ data->ek[18];
    s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ data->ek[19];
    /* round 5: */
    t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ data->ek[20];
    t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ data->ek[21];
    t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ data->ek[22];
    t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ data->ek[23];
    /* round 6: */
    s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ data->ek[24];
    s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ data->ek[25];
    s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ data->ek[26];
    s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ data->ek[27];
    /* round 7: */
    t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ data->ek[28];
    t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ data->ek[29];
    t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ data->ek[30];
    t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ data->ek[31];
    /* round 8: */
    s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
        Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ data->ek[32];
    s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
        Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ data->ek[33];
    s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
        Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ data->ek[34];
    s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
        Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ data->ek[35];
    /* round 9: */
    t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
        Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ data->ek[36];
    t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
        Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ data->ek[37];
    t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
        Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ data->ek[38];
    t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
        Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ data->ek[39];
    if (data->nr > 10) {
        /* round 10: */
        s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
            Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ data->ek[40];
        s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
            Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ data->ek[41];
        s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
            Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ data->ek[42];
        s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
            Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ data->ek[43];
        /* round 11: */
        t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
            Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ data->ek[44];
        t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
            Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ data->ek[45];
        t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
            Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ data->ek[46];
        t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
            Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ data->ek[47];
        if (data->nr > 12) {
            /* round 12: */
            s0 = Te0[t0 >> 24] ^ Te1[(t1 >> 16) & 0xff] ^
                Te2[(t2 >>  8) & 0xff] ^ Te3[t3 & 0xff] ^ data->ek[48];
            s1 = Te0[t1 >> 24] ^ Te1[(t2 >> 16) & 0xff] ^
                Te2[(t3 >>  8) & 0xff] ^ Te3[t0 & 0xff] ^ data->ek[49];
            s2 = Te0[t2 >> 24] ^ Te1[(t3 >> 16) & 0xff] ^
                Te2[(t0 >>  8) & 0xff] ^ Te3[t1 & 0xff] ^ data->ek[50];
            s3 = Te0[t3 >> 24] ^ Te1[(t0 >> 16) & 0xff] ^
                Te2[(t1 >>  8) & 0xff] ^ Te3[t2 & 0xff] ^ data->ek[51];
            /* round 13: */
            t0 = Te0[s0 >> 24] ^ Te1[(s1 >> 16) & 0xff] ^
                Te2[(s2 >>  8) & 0xff] ^ Te3[s3 & 0xff] ^ data->ek[52];
            t1 = Te0[s1 >> 24] ^ Te1[(s2 >> 16) & 0xff] ^
                Te2[(s3 >>  8) & 0xff] ^ Te3[s0 & 0xff] ^ data->ek[53];
            t2 = Te0[s2 >> 24] ^ Te1[(s3 >> 16) & 0xff] ^
                Te2[(s0 >>  8) & 0xff] ^ Te3[s1 & 0xff] ^ data->ek[54];
            t3 = Te0[s3 >> 24] ^ Te1[(s0 >> 16) & 0xff] ^
                Te2[(s1 >>  8) & 0xff] ^ Te3[s2 & 0xff] ^ data->ek[55];
        }
    }
    j = data->nr << 2;
    /* apply last round and map cipher state to byte array block: */
    s0 =
        (S3[(t0 >> 24)]) ^
        (S2[(t1 >> 16) & 0xff]) ^
        (S1[(t2 >>  8) & 0xff]) ^
        (S0[(t3) & 0xff]) ^ data->ek[0+j];
    s1 =
        (S3[(t1 >> 24)]) ^
        (S2[(t2 >> 16) & 0xff]) ^
        (S1[(t3 >>  8) & 0xff]) ^
        (S0[(t0) & 0xff]) ^ data->ek[1+j];
    s2 =
        (S3[(t2 >> 24)]) ^
        (S2[(t3 >> 16) & 0xff]) ^
        (S1[(t0 >>  8) & 0xff]) ^
        (S0[(t1) & 0xff]) ^ data->ek[2+j];
    s3 =
        (S3[(t3 >> 24)]) ^
        (S2[(t0 >> 16) & 0xff]) ^
        (S1[(t1 >>  8) & 0xff]) ^
        (S0[(t2) & 0xff]) ^ data->ek[3+j];

    *(uint*)output = SWAP(s0);
    *(uint*)&output[4] = SWAP(s1);
    *(uint*)&output[8] = SWAP(s2);
    *(uint*)&output[12] = SWAP(s3);
}

void
aes_decrypt(AES *data, uchar *ct, uchar *output)
{
    int j;

    /* map byte array block to cipher state and add initial round key: */
    uint s0 = (ct[ 0] << 24 | ct[ 1] << 16 | ct[ 2] << 8 | ct[ 3]) ^ data->dk[0];
    uint s1 = (ct[ 4] << 24 | ct[ 5] << 16 | ct[ 6] << 8 | ct[ 7]) ^ data->dk[1];
    uint s2 = (ct[ 8] << 24 | ct[ 9] << 16 | ct[10] << 8 | ct[11]) ^ data->dk[2];
    uint s3 = (ct[12] << 24 | ct[13] << 16 | ct[14] << 8 | ct[15]) ^ data->dk[3];
    /* round 1: */
    uint t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ data->dk[ 4];
    uint t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ data->dk[ 5];
    uint t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ data->dk[ 6];
    uint t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ data->dk[ 7];
    /* round 2: */
    s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ data->dk[ 8];
    s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ data->dk[ 9];
    s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ data->dk[10];
    s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ data->dk[11];
    /* round 3: */
    t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ data->dk[12];
    t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ data->dk[13];
    t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ data->dk[14];
    t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ data->dk[15];
    /* round 4: */
    s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ data->dk[16];
    s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ data->dk[17];
    s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ data->dk[18];
    s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ data->dk[19];
    /* round 5: */
    t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ data->dk[20];
    t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ data->dk[21];
    t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ data->dk[22];
    t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ data->dk[23];
    /* round 6: */
    s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ data->dk[24];
    s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ data->dk[25];
    s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ data->dk[26];
    s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ data->dk[27];
    /* round 7: */
    t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ data->dk[28];
    t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ data->dk[29];
    t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ data->dk[30];
    t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ data->dk[31];
    /* round 8: */
    s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
        Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ data->dk[32];
    s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
        Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ data->dk[33];
    s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
        Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ data->dk[34];
    s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
        Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ data->dk[35];
    /* round 9: */
    t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
        Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ data->dk[36];
    t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
        Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ data->dk[37];
    t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
        Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ data->dk[38];
    t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
        Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ data->dk[39];
    if (data->nr > 10) {
        /* round 10: */
        s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
            Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ data->dk[40];
        s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
            Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ data->dk[41];
        s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
            Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ data->dk[42];
        s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
            Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ data->dk[43];
        /* round 11: */
        t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
            Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ data->dk[44];
        t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
            Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ data->dk[45];
        t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
            Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ data->dk[46];
        t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
            Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ data->dk[47];
        if (data->nr > 12) {
            /* round 12: */
            s0 = Td0[t0 >> 24] ^ Td1[(t3 >> 16) & 0xff] ^
                Td2[(t2 >>  8) & 0xff] ^ Td3[t1 & 0xff] ^ data->dk[48];
            s1 = Td0[t1 >> 24] ^ Td1[(t0 >> 16) & 0xff] ^
                Td2[(t3 >>  8) & 0xff] ^ Td3[t2 & 0xff] ^ data->dk[49];
            s2 = Td0[t2 >> 24] ^ Td1[(t1 >> 16) & 0xff] ^
                Td2[(t0 >>  8) & 0xff] ^ Td3[t3 & 0xff] ^ data->dk[50];
            s3 = Td0[t3 >> 24] ^ Td1[(t2 >> 16) & 0xff] ^
                Td2[(t1 >>  8) & 0xff] ^ Td3[t0 & 0xff] ^ data->dk[51];
            /* round 13: */
            t0 = Td0[s0 >> 24] ^ Td1[(s3 >> 16) & 0xff] ^
                Td2[(s2 >>  8) & 0xff] ^ Td3[s1 & 0xff] ^ data->dk[52];
            t1 = Td0[s1 >> 24] ^ Td1[(s0 >> 16) & 0xff] ^
                Td2[(s3 >>  8) & 0xff] ^ Td3[s2 & 0xff] ^ data->dk[53];
            t2 = Td0[s2 >> 24] ^ Td1[(s1 >> 16) & 0xff] ^
                Td2[(s0 >>  8) & 0xff] ^ Td3[s3 & 0xff] ^ data->dk[54];
            t3 = Td0[s3 >> 24] ^ Td1[(s2 >> 16) & 0xff] ^
                Td2[(s1 >>  8) & 0xff] ^ Td3[s0 & 0xff] ^ data->dk[55];
        }
    }
    j = data->nr << 2;
    /* apply last round and map cipher state to byte array block: */
    s0 =
        (Si3[(t0 >> 24)]) ^
        (Si2[(t3 >> 16) & 0xff]) ^
        (Si1[(t2 >>  8) & 0xff]) ^
        (Si0[(t1) & 0xff]) ^ data->dk[0+j];
    s1 =
        (Si3[(t1 >> 24)]) ^
        (Si2[(t0 >> 16) & 0xff]) ^
        (Si1[(t3 >>  8) & 0xff]) ^
        (Si0[(t2) & 0xff]) ^ data->dk[1+j];
    s2 =
        (Si3[(t2 >> 24)]) ^
        (Si2[(t1 >> 16) & 0xff]) ^
        (Si1[(t0 >>  8) & 0xff]) ^
        (Si0[(t3) & 0xff]) ^ data->dk[2+j];
    s3 =
        (Si3[(t3 >> 24)]) ^
        (Si2[(t2 >> 16) & 0xff]) ^
        (Si1[(t1 >>  8) & 0xff]) ^
        (Si0[(t0) & 0xff]) ^ data->dk[3+j];

    *(uint*)output = SWAP(s0);
    *(uint*)&output[4] = SWAP(s1);
    *(uint*)&output[8] = SWAP(s2);
    *(uint*)&output[12] = SWAP(s3);
}

void
xor(const uchar *a, uchar *b)
{
    int i;

    for (i = 0; i < BLOCK_SIZE; i++) b[i] = a[i] ^ b[i];
}

void
set_state(const uchar *block, uchar *buffer)
{
    MEMCPY(buffer, block, uchar, BLOCK_SIZE);
}

uchar*
aes_encrypt_block(AES *data, const uchar *block)
{
    uchar   *state = data->state;

    set_state(block, data->state);

    switch (data->mode) {
        case MODE_ECB:
            aes_encrypt(data, data->state, data->state);
            break;
        case MODE_CBC:
            xor(data->iv, data->state);
            aes_encrypt(data, data->state, data->iv);
            state = data->iv;
            break;
        case MODE_OFB:
            aes_encrypt(data, data->iv, data->iv);
            xor(data->iv, data->state);
            break;
        case MODE_CFB:
            aes_encrypt(data, data->iv, data->iv);
            xor(data->state, data->iv);
            state = data->iv;
            break;
    }
    return state;
}

uchar*
aes_decrypt_block(AES *data, const uchar *block)
{
    uchar   *state = data->state;

    set_state(block, data->state);

    switch (data->mode) {
        case MODE_ECB:
            aes_decrypt(data, data->state, data->state);
            break;
        case MODE_CBC:
            aes_decrypt(data, data->state, data->state2);
            xor(data->iv, data->state2);
            set_state(block, data->iv);
            state = data->state2;
            break;
        case MODE_OFB:
            aes_encrypt(data, data->iv, data->iv);
            xor(data->iv, data->state);
            break;
        case MODE_CFB:
            aes_encrypt(data, data->iv, data->state2);
            xor(data->state, data->state2);
            set_state(block, data->iv);
            state = data->state2;
            break;
    }
    return state;
}

static VALUE
rb_aes_encrypt_block(VALUE self, VALUE block)
{
    return rb_str_new(aes_encrypt_block(DATA_PTR(self), RSTRING(block)->ptr), BLOCK_SIZE);
}

static VALUE
rb_aes_decrypt_block(VALUE self, VALUE block)
{
    return rb_str_new(aes_decrypt_block(DATA_PTR(self), RSTRING(block)->ptr), BLOCK_SIZE);
}

void
aes_encrypt_blocks(AES *data, int len, const char* ptr, VALUE ct)
{
    if (len % BLOCK_SIZE) rb_raise(rb_eRuntimeError, "Bad block length");
    for (; len >= BLOCK_SIZE; len -= BLOCK_SIZE, ptr += BLOCK_SIZE)
        rb_str_cat(ct, aes_encrypt_block(data, ptr), BLOCK_SIZE);
}

void
aes_decrypt_blocks(AES *data, int len, const char* ptr, VALUE pt)
{
    if (len % BLOCK_SIZE) rb_raise(rb_eRuntimeError, "Bad block length");
    for (; len >= BLOCK_SIZE; len -= BLOCK_SIZE, ptr += BLOCK_SIZE)
        rb_str_cat(pt, aes_decrypt_block(data, ptr), BLOCK_SIZE);
}

static VALUE
rb_aes_encrypt_blocks(VALUE self, VALUE buffer)
{
    AES     *data = DATA_PTR(self);
    VALUE   ct = rb_str_new("", 0);

    aes_encrypt_blocks(data, RSTRING(buffer)->len, RSTRING(buffer)->ptr, ct);

    return ct;
}

static VALUE
rb_aes_decrypt_blocks(VALUE self, VALUE buffer)
{
    AES     *data = DATA_PTR(self);
    VALUE   pt = rb_str_new("", 0);

    aes_decrypt_blocks(data, RSTRING(buffer)->len, RSTRING(buffer)->ptr, pt);

    return pt;
}

static VALUE
rb_aes_encrypt_buffer(VALUE self, VALUE buffer)
{
    AES         *data = DATA_PTR(self);
    const char  *ptr = RSTRING(buffer)->ptr;
    int         i, len = RSTRING(buffer)->len;
    uchar       pad, *buf;
    VALUE       ct = rb_str_new("", 0);

    for (; len >= BLOCK_SIZE; len -= BLOCK_SIZE, ptr += BLOCK_SIZE)
        rb_str_cat(ct, aes_encrypt_block(data, ptr), BLOCK_SIZE);
    if (len > 0 && len < BLOCK_SIZE) {
        pad = BLOCK_SIZE - len % BLOCK_SIZE;
        buf = ALLOC_N(uchar, BLOCK_SIZE);
        MEMCPY(buf, ptr, uchar, len);
        for (i = len; i < BLOCK_SIZE; i++)
            buf[i] = pad;
        rb_str_cat(ct, aes_encrypt_block(data, buf), BLOCK_SIZE);
        free(buf);
    }/* else
        rb_str_cat(ct, "\x0", 1);*/

    return ct;
}

static VALUE
rb_aes_decrypt_buffer(VALUE self, VALUE buffer)
{
    AES *data = DATA_PTR(self);
    const char  *ptr = RSTRING(buffer)->ptr;
    int         i, len = RSTRING(buffer)->len;
    uchar       pad;
    VALUE       pt = rb_str_new("", 0);

    for (; len >= BLOCK_SIZE; len -= BLOCK_SIZE, ptr += BLOCK_SIZE)
        rb_str_cat(pt, aes_decrypt_block(data, ptr), BLOCK_SIZE);
    if (len == 0) {
        i = RSTRING(pt)->len;
        ptr = RSTRING(pt)->ptr + i - 1;
        pad = *ptr;
        if (pad < BLOCK_SIZE) {
            for (; i > 0 && pad == *ptr; ptr--, i--, len++);
            /*if (pad != len)
                rb_raise(rb_eRuntimeError, "Bad Block Padding");*/
            if (pad == len)
                rb_str_resize(pt, i);
        }
    } else/* if (len != 1)*/
        rb_raise(rb_eRuntimeError, "Bad Block Padding");
    return pt;
}

void
encryption_key_schedule(AES *data, uchar *key)
{
    int i = 0, j;
    uint temp;

    if (data->ek) FREE(data->ek);
    data->ek = ALLOC_N(uint, 4 * (data->nr + 1));
    MEMZERO(data->ek, uint, 4 * (data->nr + 1));

    data->ek[0] = key[0] << 24 | key[1] << 16 | key[2] << 8 | key[3];
    data->ek[1] = key[4] << 24 | key[5] << 16 | key[6] << 8 | key[7];
    data->ek[2] = key[8] << 24 | key[9] << 16 | key[10] << 8 | key[11];
    data->ek[3] = key[12] << 24 | key[13] << 16 | key[14] << 8 | key[15];
    if (data->kl == 128) {
        j = 0;
        for (;;) {
            temp = data->ek[3+j];
            data->ek[4+j] = data->ek[0+j] ^
                (S3[(temp >> 16) & 0xff]) ^
                (S2[(temp >>  8) & 0xff]) ^
                (S1[(temp) & 0xff]) ^
                (S0[(temp >> 24)]) ^ RCON[i];
            data->ek[5+j] = data->ek[1+j] ^ data->ek[4+j];
            data->ek[6+j] = data->ek[2+j] ^ data->ek[5+j];
            data->ek[7+j] = data->ek[3+j] ^ data->ek[6+j];
            i += 1;
            if (i == 10) return;
            j += 4;
        }
    }
    data->ek[4] = key[16] << 24 | key[17] << 16 | key[18] << 8 | key[19];
    data->ek[5] = key[20] << 24 | key[21] << 16 | key[22] << 8 | key[23];
    if (data->kl == 192) {
        j = 0;
        for (;;) {
            temp = data->ek[ 5+j];
            data->ek[ 6+j] = data->ek[ 0+j] ^
                (S3[(temp >> 16) & 0xff]) ^
                (S2[(temp >>  8) & 0xff]) ^
                (S1[(temp) & 0xff]) ^
                (S0[(temp >> 24)]) ^ RCON[i];
            data->ek[ 7+j] = data->ek[ 1+j] ^ data->ek[ 6+j];
            data->ek[ 8+j] = data->ek[ 2+j] ^ data->ek[ 7+j];
            data->ek[ 9+j] = data->ek[ 3+j] ^ data->ek[ 8+j];
            i += 1;
            if (i == 8) return;
            data->ek[10+j] = data->ek[ 4+j] ^ data->ek[ 9+j];
            data->ek[11+j] = data->ek[ 5+j] ^ data->ek[10+j];
            j += 6;
        }
    }
    data->ek[6] = key[24] << 24 | key[25] << 16 | key[26] << 8 | key[27];
    data->ek[7] = key[28] << 24 | key[29] << 16 | key[30] << 8 | key[31];
    if (data->kl == 256) {
        j = 0;
        for (;;) {
            temp = data->ek[ 7+j];
            data->ek[ 8+j] = data->ek[ 0+j] ^
                (S3[(temp >> 16) & 0xff]) ^
                (S2[(temp >>  8) & 0xff]) ^
                (S1[(temp) & 0xff]) ^
                (S0[(temp >> 24)]) ^ RCON[i];
            data->ek[ 9+j] = data->ek[ 1+j] ^ data->ek[ 8+j];
            data->ek[10+j] = data->ek[ 2+j] ^ data->ek[ 9+j];
            data->ek[11+j] = data->ek[ 3+j] ^ data->ek[10+j];
            i += 1;
            if (i == 7) return;
            temp = data->ek[11+j];
            data->ek[12+j] = data->ek[ 4+j] ^
                (S3[(temp >> 24)]) ^
                (S2[(temp >> 16) & 0xff]) ^
                (S1[(temp >>  8) & 0xff]) ^
                (S0[(temp) & 0xff]);
            data->ek[13+j] = data->ek[ 5+j] ^ data->ek[12+j];
            data->ek[14+j] = data->ek[ 6+j] ^ data->ek[13+j];
            data->ek[15+j] = data->ek[ 7+j] ^ data->ek[14+j];
            j += 8;
        }
    }
}

void
decryption_key_schedule(AES *data, uchar *key)
{
    int i = 0, j = 4 * data->nr;
    uint w0, w1, w2, w3, temp;

    encryption_key_schedule(data, key);

    if (data->dk) FREE(data->dk);
    data->dk = ALLOC_N(uint, 4 * (data->nr + 1));
    MEMCPY(data->dk, data->ek, uint, 4 * (data->nr + 1));

    /* invert the order of the round keys:*/
    for (;;) {
        if (i >= j) break;
        temp = data->dk[i    ]; data->dk[i    ] = data->dk[j    ]; data->dk[j    ] = temp;
        temp = data->dk[i + 1]; data->dk[i + 1] = data->dk[j + 1]; data->dk[j + 1] = temp;
        temp = data->dk[i + 2]; data->dk[i + 2] = data->dk[j + 2]; data->dk[j + 2] = temp;
        temp = data->dk[i + 3]; data->dk[i + 3] = data->dk[j + 3]; data->dk[j + 3] = temp;
        i += 4; j -= 4;
    }
    /* apply the inverse MixColumn transform*/
    /* to all round keys but the first and the last:*/
    j = 0;
    for (i = 1; i < data->nr; i++) {
        j += 4;
        w0 = data->dk[j];
        w1 = data->dk[j+1];
        w2 = data->dk[j+2];
        w3 = data->dk[j+3];
        data->dk[0+j] =
            Td0[S0[(w0 >> 24)] ] ^
            Td1[S0[(w0 >> 16) & 0xff] ] ^
            Td2[S0[(w0 >>  8) & 0xff] ] ^
            Td3[S0[(w0) & 0xff] ];
        data->dk[1+j] =
            Td0[S0[(w1 >> 24)] ] ^
            Td1[S0[(w1 >> 16) & 0xff] ] ^
            Td2[S0[(w1 >>  8) & 0xff] ] ^
            Td3[S0[(w1) & 0xff] ];
        data->dk[2+j] =
            Td0[S0[(w2 >> 24)] ] ^
            Td1[S0[(w2 >> 16) & 0xff] ] ^
            Td2[S0[(w2 >>  8) & 0xff] ] ^
            Td3[S0[(w2) & 0xff] ];
        data->dk[3+j] =
            Td0[S0[(w3 >> 24)] ] ^
            Td1[S0[(w3 >> 16) & 0xff] ] ^
            Td2[S0[(w3 >>  8) & 0xff] ] ^
            Td3[S0[(w3) & 0xff] ];
    }
}

static VALUE
rb_aes_c_extension()
{
    return Qtrue;
}

static VALUE
rb_aes_init(VALUE self, VALUE kl, VALUE mode, VALUE key, VALUE iv)
{
    AES *data = DATA_PTR(self);

    data->kl = FIX2INT(kl);

    if (data->kl == 128) {
        data->nk = 4;
        data->nr = 10;
    } else if (data->kl == 192) {
        data->nk = 6;
        data->nr = 12;
    } else if (data->kl == 256) {
        data->nk = 8;
        data->nr = 14;
    } else {
        rb_raise(rb_eArgError, "Bad Key Length");
    }
    data->nb = 4;

    char *mode_str = RSTRING(mode)->ptr;
    if (!strncmp(mode_str, "ECB", 3)) data->mode = MODE_ECB;
    else if (!strncmp(mode_str, "CBC", 3)) data->mode = MODE_CBC;
    else if (!strncmp(mode_str, "CFB", 3)) data->mode = MODE_CFB;
    else if (!strncmp(mode_str, "OFB", 3)) data->mode = MODE_OFB;
    else rb_raise(rb_eArgError, "Bad AES mode");

    if (data->key) FREE(data->key);
    data->key = ALLOC_N(uchar, 32);
    MEMCPY(data->key, RSTRING(key)->ptr, uchar, RSTRING(key)->len > 32 ? 32 : RSTRING(key)->len);

    if (data->iv) FREE(data->iv);
    if (NIL_P(iv)) {
        data->iv = NULL;
    } else {
        data->iv = ALLOC_N(uchar, BLOCK_SIZE);
        MEMCPY(data->iv, RSTRING(iv)->ptr, uchar, BLOCK_SIZE);
    }

    decryption_key_schedule(data, data->key);

    return self;
}

static void
rb_aes_mark(AES *data)
{
}

static void
rb_aes_free(AES *data)
{
    if (data) {
        if (data->state) FREE(data->state);
        if (data->state2) FREE(data->state2);
        if (data->key) FREE(data->key);
        if (data->iv) FREE(data->iv);
        if (data->ek) FREE(data->ek);
        if (data->dk) FREE(data->dk);
        FREE(data);
    }
}

static VALUE
rb_aes_alloc(VALUE klass)
{
    VALUE   obj;
    AES     *data;

    data = ALLOC(AES);
    MEMZERO(data, AES, 1);

    data->state = ALLOC_N(uchar, BLOCK_SIZE);
    MEMZERO(data->state, uchar, BLOCK_SIZE);

    data->state2 = ALLOC_N(uchar, BLOCK_SIZE);
    MEMZERO(data->state2, uchar, BLOCK_SIZE);

    data->key = ALLOC_N(uchar, 32);
    MEMZERO(data->key, uchar, 32);

    data->iv = ALLOC_N(uchar, BLOCK_SIZE);
    MEMZERO(data->iv, uchar, BLOCK_SIZE);

    obj = Data_Wrap_Struct(klass, rb_aes_mark, rb_aes_free, data);

    return obj;
}

static VALUE
rb_aes_initialize(VALUE self, VALUE kl, VALUE mode, VALUE key, VALUE iv)
{
    rb_aes_init(self, kl, mode, key, iv);

    return Qnil;
}

void Init_aes_alg()
{
    rb_cAes = rb_define_class("AesAlg", rb_cObject);
    rb_define_alloc_func(rb_cAes, rb_aes_alloc);
    rb_define_method(rb_cAes, "initialize", rb_aes_initialize, 4);
    rb_define_method(rb_cAes, "init", rb_aes_init, 4);
    rb_define_method(rb_cAes, "encrypt_block", rb_aes_encrypt_block, 1);
    rb_define_method(rb_cAes, "decrypt_block", rb_aes_decrypt_block, 1);
    rb_define_method(rb_cAes, "encrypt_blocks", rb_aes_encrypt_blocks, 1);
    rb_define_method(rb_cAes, "decrypt_blocks", rb_aes_decrypt_blocks, 1);
    rb_define_method(rb_cAes, "encrypt_buffer", rb_aes_encrypt_buffer, 1);
    rb_define_method(rb_cAes, "decrypt_buffer", rb_aes_decrypt_buffer, 1);
    rb_define_method(rb_cAes, "c_extension", rb_aes_c_extension, 0);
}
