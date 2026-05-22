#include <stdlib.h>
#include <string.h>

struct realloc_header
{
	int ptr;
	int size;
};

void *realloc(void *ptr, size_t size)
{
	struct realloc_header *header;
	void *new_ptr;
	size_t old_size;

	if (ptr == 0)
		return malloc(size);

	if (size == 0)
	{
		free(ptr);
		return 0;
	}

	new_ptr = malloc(size);
	if (new_ptr == 0 || new_ptr == ptr)
		return new_ptr;

	header = ((struct realloc_header *) ptr) - 1;
	old_size = (header->size - 1) * sizeof(struct realloc_header);
	if (old_size > size)
		old_size = size;

	memcpy(new_ptr, ptr, old_size);
	free(ptr);
	return new_ptr;
}
