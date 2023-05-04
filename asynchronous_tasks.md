# Asynchronous Tasks in Fortran

## Introduction

The principle of asynchrony is fundamental to many aspects of computing,
and appears in many forms, many of which already overlap with the use of
Fortran.  Fortran supports asynchronous execution already via coarrays,
since two coarrays execute independent of one another unless explicitly
synchronized.  However, some use cases for asynchrony are a poor fit for
coarrays, either due to the need for data to be distributed across images
and explicitly communicated between them, or because the number of images
is fixed and - except for termination - does not change throughout the
execution of a program.

It is also possible to achieve asynchrony using DO CONCURRENT, but this
assumes that an implementation generates the appropriate type of paralleism
required for asynchronous execution.  In any case, DO CONCURRENT imposes
a number of restrictions on the code that can be executed within that scope,
particularly that impure procedures are not permitted.  This excludes the
possibility of long-running and/or complex tasks that cannot be contorted
to fit within the scope of a single DO CONCURRENT region.

## Related Efforts

