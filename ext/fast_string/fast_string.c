#include <ruby.h>
#include <string.h>
#include <stdint.h>

static const int whitespace_table[256] = {
    [' '] = 1, ['\t'] = 1, ['\n'] = 1, ['\r'] = 1, ['\f'] = 1, ['\v'] = 1
};

static VALUE rb_string_fs_count(VALUE self, VALUE target) {
    Check_Type(target, T_STRING);
    if (RSTRING_LEN(target) != 1)
        rb_raise(rb_eArgError, "target must be a single character");

    char *ptr = RSTRING_PTR(self);
    long len = RSTRING_LEN(self);
    unsigned char target_char = (unsigned char)RSTRING_PTR(target)[0];
    long count = 0;
    char *current = ptr;
    char *end = ptr + len;

    while (current < end) {
        char *found = memchr(current, target_char, end - current);
        if (found == NULL) break;
        count++;
        current = found + 1;
    }
    return LONG2NUM(count);
}

static VALUE rb_string_fs_lines(VALUE self) {
    char *ptr = RSTRING_PTR(self);
    long len = RSTRING_LEN(self);
    long count = 0;
    char *current = ptr;
    char *end = ptr + len;

    while (current < end) {
        char *found = memchr(current, '\n', end - current);
        if (found == NULL) break;
        count++;
        current = found + 1;
    }
    return LONG2NUM(count);
}

static VALUE rb_string_fs_blank(VALUE self) {
    char *ptr = RSTRING_PTR(self);
    long len = RSTRING_LEN(self);

    for (long i = 0; i < len; i++) {
        if (!whitespace_table[(unsigned char)ptr[i]])
            return Qfalse;
    }
    return Qtrue;
}

static VALUE rb_string_fs_each_line(VALUE self) {
    RETURN_ENUMERATOR(self, 0, 0);

    char *ptr = RSTRING_PTR(self);
    long len = RSTRING_LEN(self);
    if (len == 0) return self;

    char *current = ptr;
    char *end = ptr + len;

    while (current < end) {
        char *found = memchr(current, '\n', end - current);
        long line_len = found ? (found - current + 1) : (end - current);
        rb_yield(rb_str_subseq(self, current - ptr, line_len));
        current += line_len;
    }
    return self;
}

static VALUE rb_string_fs_trim(VALUE self) {
    char *ptr = RSTRING_PTR(self);
    long len = RSTRING_LEN(self);
    long start = 0;
    long end = len;

    while (start < end && whitespace_table[(unsigned char)ptr[start]])
        start++;
    while (end > start && whitespace_table[(unsigned char)ptr[end - 1]])
        end--;

    if (start == 0 && end == len)
        return rb_str_dup(self);

    return rb_str_subseq(self, start, end - start);
}

static VALUE rb_string_fs_byte_replace(VALUE self, VALUE from, VALUE to) {
    Check_Type(from, T_STRING);
    Check_Type(to, T_STRING);
    if (RSTRING_LEN(from) != 1 || RSTRING_LEN(to) != 1)
        rb_raise(rb_eArgError, "from and to must be single characters");

    char *ptr = RSTRING_PTR(self);
    long len = RSTRING_LEN(self);
    unsigned char from_byte = (unsigned char)RSTRING_PTR(from)[0];
    unsigned char to_byte = (unsigned char)RSTRING_PTR(to)[0];

    if (from_byte == to_byte)
        return rb_str_dup(self);

    VALUE result = rb_str_new(ptr, len);
    rb_enc_associate(result, rb_enc_get(self));
    char *out = RSTRING_PTR(result);
    char *current = out;
    char *end = out + len;

    while (current < end) {
        char *found = memchr(current, from_byte, end - current);
        if (found == NULL) break;
        *found = (char)to_byte;
        current = found + 1;
    }
    return result;
}

static VALUE rb_string_fs_byte_delete(VALUE self, VALUE target) {
    Check_Type(target, T_STRING);
    if (RSTRING_LEN(target) != 1)
        rb_raise(rb_eArgError, "target must be a single character");

    char *ptr = RSTRING_PTR(self);
    long len = RSTRING_LEN(self);
    unsigned char target_byte = (unsigned char)RSTRING_PTR(target)[0];

    VALUE result = rb_str_buf_new(len);
    rb_enc_associate(result, rb_enc_get(self));
    char *out = RSTRING_PTR(result);
    long out_len = 0;
    char *current = ptr;
    char *end = ptr + len;

    while (current < end) {
        char *found = memchr(current, target_byte, end - current);
        if (found == NULL) {
            long chunk = end - current;
            memcpy(out + out_len, current, chunk);
            out_len += chunk;
            break;
        }
        long chunk = found - current;
        if (chunk > 0) {
            memcpy(out + out_len, current, chunk);
            out_len += chunk;
        }
        current = found + 1;
    }

    rb_str_set_len(result, out_len);
    return result;
}

void Init_fast_string(void) {
    rb_define_method(rb_cString, "fs_count",        rb_string_fs_count,        1);
    rb_define_method(rb_cString, "fs_lines",        rb_string_fs_lines,        0);
    rb_define_method(rb_cString, "fs_blank?",       rb_string_fs_blank,        0);
    rb_define_method(rb_cString, "fs_each_line",    rb_string_fs_each_line,    0);
    rb_define_method(rb_cString, "fs_trim",         rb_string_fs_trim,         0);
    rb_define_method(rb_cString, "fs_byte_replace", rb_string_fs_byte_replace, 2);
    rb_define_method(rb_cString, "fs_byte_delete",  rb_string_fs_byte_delete,  1);
}
