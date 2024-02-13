#include <stdio.h>
#include <stdint.h>

typedef int16_t fixed_point;

#define FRACTIONAL_BITS 9 // converting to Q7.9
#define FLOAT2FIXED(x) ((fixed_point)((x) * (1 << FRACTIONAL_BITS)))
#define FIXED2FLOAT(x) (((float)(x)) / (1 << FRACTIONAL_BITS))

int main()
{
   fixed_point val[12];
   int n;
   float mse = 0.0F;
   float val_fixed_to_float[12];
   float temp = 0.0F;
   float y[12];
   float x[] = {0.5F, -0.23F, 0.34F, 0.89F, 0.11F, -0.22F, 0.13F, 0.15F, 0.67F, -0.15F, -0.99F};

   for (n = 0; n < 11; n++)
   {
      y[n] = -2.375F * x[n] + 1.24F * temp;
      temp = y[n];
      printf("y[%d](float) = %f, ", n, y[n]);

      val[n] = FLOAT2FIXED(y[n]);
      printf("y[%d](float to fixed) = %X, ", n, val[n] & 0xffff);

      val_fixed_to_float[n] = FIXED2FLOAT(val[n]);
      printf("y[%d](fixed to float) = %f \n", n, val_fixed_to_float[n]);
   }

   for (n = 0; n < 11; n++) //calcuate mean squared error
   {
      mse += (val_fixed_to_float[n] - y[n]) * (val_fixed_to_float[n] - y[n]);
   }
   
   printf("MSE = %f\n", (mse / 12));
}