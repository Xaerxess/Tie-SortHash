requires 'perl', '5.006000';
requires 'strict';
requires 'warnings';

on build => sub {
    requires 'ExtUtils::MakeMaker';
};

on test => sub {
    requires 'Test::More', '0.88';
};
