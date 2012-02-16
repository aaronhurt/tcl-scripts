/*
 * blowfish.c -- part of blowfish.mod
 */

#include "blowfish.h"
#include "bf_tab.h"             /* P-box P-array, S-box */

/* Each box takes up 4k so be very careful here */
#define BOXES 3

/* #define S(x,i) (bf_S[i][x.w.byte##i]) */
#define S0(x) (bf_S[0][x.w.byte0])
#define S1(x) (bf_S[1][x.w.byte1])
#define S2(x) (bf_S[2][x.w.byte2])
#define S3(x) (bf_S[3][x.w.byte3])
#define bf_F(x) (((S0(x) + S1(x)) ^ S2(x)) + S3(x))
#define ROUND(a,b,n) (a.word ^= bf_F(b) ^ bf_P[n])

/* Keep a set of rotating P & S boxes */
static struct box_t {
  u_32bit_t *P;
  u_32bit_t **S;
  char key[81];
  char keybytes;
  time_t lastuse;
} box[BOXES];

/* static u_32bit_t bf_P[bf_N+2]; */
/* static u_32bit_t bf_S[4][256]; */
static u_32bit_t *bf_P;
static u_32bit_t **bf_S;

int blowfish_expmem()
{
  int i, tot = 0;

  for (i = 0; i < BOXES; i++)
    if (box[i].P != NULL) {
      tot += ((bf_N + 2) * sizeof(u_32bit_t));
      tot += (4 * sizeof(u_32bit_t *));
      tot += (4 * 256 * sizeof(u_32bit_t));
    }
  return tot;
}

void blowfish_encipher(u_32bit_t *xl, u_32bit_t *xr)
{
  union aword Xl;
  union aword Xr;

  Xl.word = *xl;
  Xr.word = *xr;

  Xl.word ^= bf_P[0];
  ROUND(Xr, Xl, 1);
  ROUND(Xl, Xr, 2);
  ROUND(Xr, Xl, 3);
  ROUND(Xl, Xr, 4);
  ROUND(Xr, Xl, 5);
  ROUND(Xl, Xr, 6);
  ROUND(Xr, Xl, 7);
  ROUND(Xl, Xr, 8);
  ROUND(Xr, Xl, 9);
  ROUND(Xl, Xr, 10);
  ROUND(Xr, Xl, 11);
  ROUND(Xl, Xr, 12);
  ROUND(Xr, Xl, 13);
  ROUND(Xl, Xr, 14);
  ROUND(Xr, Xl, 15);
  ROUND(Xl, Xr, 16);
  Xr.word ^= bf_P[17];

  *xr = Xl.word;
  *xl = Xr.word;
}

void blowfish_decipher(u_32bit_t *xl, u_32bit_t *xr)
{
  union aword Xl;
  union aword Xr;

  Xl.word = *xl;
  Xr.word = *xr;

  Xl.word ^= bf_P[17];
  ROUND(Xr, Xl, 16);
  ROUND(Xl, Xr, 15);
  ROUND(Xr, Xl, 14);
  ROUND(Xl, Xr, 13);
  ROUND(Xr, Xl, 12);
  ROUND(Xl, Xr, 11);
  ROUND(Xr, Xl, 10);
  ROUND(Xl, Xr, 9);
  ROUND(Xr, Xl, 8);
  ROUND(Xl, Xr, 7);
  ROUND(Xr, Xl, 6);
  ROUND(Xl, Xr, 5);
  ROUND(Xr, Xl, 4);
  ROUND(Xl, Xr, 3);
  ROUND(Xr, Xl, 2);
  ROUND(Xl, Xr, 1);
  Xr.word ^= bf_P[0];

  *xl = Xr.word;
  *xr = Xl.word;
}

void blowfish_init(u_8bit_t *key, int keybytes)
{
  int i, j, bx;
  time_t lowest;
  u_32bit_t data;
  u_32bit_t datal;
  u_32bit_t datar;
  union aword temp;

  /* drummer: Fixes crash if key is longer than 80 char. This may cause the key
   *          to not end with \00 but that's no problem.
   */
  if (keybytes > 80)
    keybytes = 80;

  /* Is buffer already allocated for this? */
  for (i = 0; i < BOXES; i++)
    if (box[i].P != NULL) {
      if ((box[i].keybytes == keybytes) &&
          (!strncmp((char *) (box[i].key), (char *) key, keybytes))) {
        /* Match! */
        box[i].lastuse = time(NULL);
        bf_P = box[i].P;
        bf_S = box[i].S;
        return;
      }
    }
  /* No pre-allocated buffer: make new one */
  /* Set 'bx' to empty buffer */
  bx = -1;
  for (i = 0; i < BOXES; i++) {
    if (box[i].P == NULL) {
      bx = i;
      i = BOXES + 1;
    }
  }
  if (bx < 0) {
    /* Find oldest */
    lowest = time(NULL);
    for (i = 0; i < BOXES; i++)
      if (box[i].lastuse <= lowest) {
        lowest = box[i].lastuse;
        bx = i;
      }
    free(box[bx].P);
    for (i = 0; i < 4; i++)
      free(box[bx].S[i]);
    free(box[bx].S);
  }
  /* Initialize new buffer */
  /* uh... this is over 4k */
  box[bx].P = (u_32bit_t *) malloc((bf_N + 2) * sizeof(u_32bit_t));
  box[bx].S = (u_32bit_t **) malloc(4 * sizeof(u_32bit_t *));
  for (i = 0; i < 4; i++)
    box[bx].S[i] = (u_32bit_t *) malloc(256 * sizeof(u_32bit_t));
  bf_P = box[bx].P;
  bf_S = box[bx].S;
  box[bx].keybytes = keybytes;
  strncpy(box[bx].key, key, keybytes);
  box[bx].key[keybytes] = 0;
  box[bx].lastuse = time(NULL);
  /* Robey: Reset blowfish boxes to initial state
   * (I guess normally it just keeps scrambling them, but here it's
   * important to get the same encrypted result each time)
   */
  for (i = 0; i < bf_N + 2; i++)
    bf_P[i] = initbf_P[i];
  for (i = 0; i < 4; i++)
    for (j = 0; j < 256; j++)
      bf_S[i][j] = initbf_S[i][j];

  j = 0;
  if (keybytes > 0) {           /* drummer: fixes crash if key=="" */
    for (i = 0; i < bf_N + 2; ++i) {
      temp.word = 0;
      temp.w.byte0 = key[j];
      temp.w.byte1 = key[(j + 1) % keybytes];
      temp.w.byte2 = key[(j + 2) % keybytes];
      temp.w.byte3 = key[(j + 3) % keybytes];
      data = temp.word;
      bf_P[i] = bf_P[i] ^ data;
      j = (j + 4) % keybytes;
    }
  }
  datal = 0x00000000;
  datar = 0x00000000;
  for (i = 0; i < bf_N + 2; i += 2) {
    blowfish_encipher(&datal, &datar);
    bf_P[i] = datal;
    bf_P[i + 1] = datar;
  }
  for (i = 0; i < 4; ++i) {
    for (j = 0; j < 256; j += 2) {
      blowfish_encipher(&datal, &datar);
      bf_S[i][j] = datal;
      bf_S[i][j + 1] = datar;
    }
  }
}

/* Of course, if you change either of these, then your userfile will
 * no longer be able to be shared. :)
 */
#define SALT1  0xdeadd061
#define SALT2  0x23f6b095

/* Convert 64-bit encrypted password to text for userfile */
static char *base64 =
            "./0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

int base64dec(char c)
{
  int i;

  for (i = 0; i < 64; i++)
    if (base64[i] == c)
      return i;
  return 0;
}

void blowfish_encrypt_pass(char *text, char *new)
{
  u_32bit_t left, right;
  int n;
  char *p;

  blowfish_init((unsigned char *) text, strlen(text));
  left = SALT1;
  right = SALT2;
  blowfish_encipher(&left, &right);
  p = new;
  *p++ = '+';                   /* + means encrypted pass */
  n = 32;
  while (n > 0) {
    *p++ = base64[right & 0x3f];
    right = (right >> 6);
    n -= 6;
  }
  n = 32;
  while (n > 0) {
    *p++ = base64[left & 0x3f];
    left = (left >> 6);
    n -= 6;
  }
  *p = 0;
}

/* Returned string must be freed when done with it!
 */
char *encrypt_string(char *key, char *str)
{
  u_32bit_t left, right;
  unsigned char *p;
  char *s, *dest, *d;
  int i;

  /* Pad fake string with 8 bytes to make sure there's enough */
  s = (char *) malloc(strlen(str) + 9);
  strcpy(s, str);
  if ((!key) || (!key[0]))
    return s;
  p = s;
  dest = (char *) malloc((strlen(str) + 9) * 2);
  while (*p)
    p++;
  for (i = 0; i < 8; i++)
    *p++ = 0;
  blowfish_init((unsigned char *) key, strlen(key));
  p = s;
  d = dest;
  while (*p) {
    left = ((*p++) << 24);
    left += ((*p++) << 16);
    left += ((*p++) << 8);
    left += (*p++);
    right = ((*p++) << 24);
    right += ((*p++) << 16);
    right += ((*p++) << 8);
    right += (*p++);
    blowfish_encipher(&left, &right);
    for (i = 0; i < 6; i++) {
      *d++ = base64[right & 0x3f];
      right = (right >> 6);
    }
    for (i = 0; i < 6; i++) {
      *d++ = base64[left & 0x3f];
      left = (left >> 6);
    }
  }
  *d = 0;
  free(s);
  return dest;
}

/* Returned string must be freed when done with it!
 */
char *decrypt_string(char *key, char *str)
{
  u_32bit_t left, right;
  char *p, *s, *dest, *d;
  int i;

  /* Pad encoded string with 0 bits in case it's bogus */
  s = (char *) malloc(strlen(str) + 12);
  strcpy(s, str);
  if ((!key) || (!key[0]))
    return s;
  p = s;
  dest = (char *) malloc(strlen(str) + 12);
  while (*p)
    p++;
  for (i = 0; i < 12; i++)
    *p++ = 0;
  blowfish_init((unsigned char *) key, strlen(key));
  p = s;
  d = dest;
  while (*p) {
    right = 0L;
    left = 0L;
    for (i = 0; i < 6; i++)
      right |= (base64dec(*p++)) << (i * 6);
    for (i = 0; i < 6; i++)
      left |= (base64dec(*p++)) << (i * 6);
    blowfish_decipher(&left, &right);
    for (i = 0; i < 4; i++)
      *d++ = (left & (0xff << ((3 - i) * 8))) >> ((3 - i) * 8);
    for (i = 0; i < 4; i++)
      *d++ = (right & (0xff << ((3 - i) * 8))) >> ((3 - i) * 8);
  }
  *d = 0;
  free(s);
  return dest;
}

void init_blowfish()
{
    int i;
    /* Initialize buffered boxes */
    for (i = 0; i < BOXES; i++) {
      box[i].P = NULL;
      box[i].S = NULL;
      box[i].key[0] = 0;
      box[i].lastuse = 0L;
    }
}
