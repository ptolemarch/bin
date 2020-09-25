#include <stdio.h>

main()
{
    int c;
    int nonnull=0, total=0;
    float percentage;

    while ((c = getchar()) != EOF) {
	total++;
	if (c != '\0') {
	    nonnull++;
	}
    }

    percentage = ((float)nonnull / (float)total) * 100;

    printf("[%8d/%8d]  %2.4f %%\n", nonnull, total, percentage);
}
