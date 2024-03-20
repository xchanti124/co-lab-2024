#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>

int my_diff(const char *a, const char *b, bool flag_i, bool flag_B)
{
    FILE *file_a = fopen(a, "r");
    if (file_a == NULL)
    {
        return -1;
    }

    char current_line_a[1025]; // creating a buffer of characters with length of 1025
    bool file_a_end = false;

    FILE *file_b = fopen(b, "r");
    if (file_b == NULL)
    {
        fclose(file_a);
        return -1;
    }

    char current_line_b[1025]; // creating a buffer of characters with length of 1025
    bool file_b_end = false;

    int cur_line = 0;
    bool return_value = 0;

    // loop keeps on executing while file_a is not at thend, file_b is not at the end
    // or while neither of them at the end. loop stops when both files have reached the end.
    while (!file_a_end || !file_b_end)
    {
        cur_line++;

        // if file_a isn't at the end, we're trying to read the next line
        if (!file_a_end)
        {
            // try to put the next line of file_a into current_line_a
            char *result = fgets(current_line_a, sizeof(current_line_a), file_a);

            // if fgets returns a null ptr, that means we're at the end of the file
            if (result == NULL)
            {
                // mark file_a as ended
                file_a_end = true;
            }
        }

        // 1 hello world        //1 hello world
        // 2                    //2 line2 content
        // 3 line2 content      //3
        // 4                    //4

        // if file_b isn't at the end, we're trying to read the next line
        if (!file_b_end)
        {

            // try to put the next line of file_b into current_line_b
            char *result = fgets(current_line_b, sizeof(current_line_b), file_b);

            // if fgets returns a null ptr, that means we're at the end of the file
            if (result == NULL)
            {
                // mark file_b as ended
                file_b_end = true;
            }
        }

        // if line_a_end is true, that means we don't have anymore lines from file a, but we do have a line from file_b
        // assume current line_a is empty line
        char *line_a_to_check;
        // char *line_a_to_check; = !file_a_end ? current_line_a : "\n";

        if (!file_a_end)
        {
            line_a_to_check = current_line_a;
        }
        else
        {
            line_a_to_check = "\n";
        }

        // if line_b_end is true, that means we don't have anymore lines from file b, but we do have a line from file_a
        // assume current line_b is empty line
        char *line_b_to_check = !file_b_end ? current_line_b : "\n";

        if (!file_b_end)
        {
            line_b_to_check = current_line_b;
        }
        else
        {
            line_b_to_check = "\n";
        }

        bool are_lines_different;

        if (flag_i)
        {
            // compare two lines, if strcmp returns 0 then the lines are the same, if not, then they're different
            are_lines_different = strcasecmp(line_a_to_check, line_b_to_check) != 0;
        }
        else
        {
            // compare two lines, if strcmp returns 0 then the lines are the same, if not, then they're different
            are_lines_different = strcmp(line_a_to_check, line_b_to_check) != 0;
        }

        if (are_lines_different)
        {
            return_value = 1;

            printf("%dc%d\n", cur_line, cur_line);
            printf("< %s", line_a_to_check);
            printf("---\n");
            printf("> %s", line_b_to_check);
        }
    }

    fclose(file_a);
    fclose(file_b);

    return return_value;
}

int main(int argc, char *argv[])
{
    bool flag_i = false;
    bool flag_B = false;

    for (int i = 0; i < argc; i++)
    {
        if (strcmp(argv[i], "-i") == 0)
        {
            flag_i = true;
        }

        if (strcmp(argv[i], "-B") == 0)
        {
            flag_B = true;
        }
    }

    my_diff(argv[1], argv[2], flag_i, flag_B);

    return 0;
}
