#include <stdio.h>
#include <unistd.h>

int ok(int val, char *msg)
{
	printf("%s: %s\n", val ? "okay" : "FAIL", msg);
	return val ? 0 : 1;
}

int check_one(void)
{
	return ok(1 == 1, "1 == 1");
}

int check_two(void)
{
//	return ok(2 == 3, "2 == 3");
	return ok(2 == 2, "2 == 2");
}

void app_main(void)
{
	printf("Starting tests\n");

	int failures = 0;

	failures += check_one();
	failures += check_two();
	printf("Tests completed with %d failures\n", failures);
	printf("%d\n", failures);
	fflush(stdout);
	sleep(1);

	printf("sleeping for 10 seconds\n");
	fflush(stdout);
	sleep(10);

	printf("halting\n");
	fflush(stdout);
}
