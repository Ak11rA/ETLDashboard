/*-----------------------------------------------------------------------------
|| DDL for Package Body DBATOOLS
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE BODY "DWH_MTD"."DBATOOLS" AS
-- (c) Loopback.ORG GmbH, info@loopback.org

    raw_key   RAW(128) := hextoraw('0123456789ABCDEF');

    PROCEDURE dmesg (
        p_text       VARCHAR2,
        p_scope      VARCHAR2,
        p_severity   NUMBER
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        dbms_output.put_line(SYSDATE
                             || '|'
                             || p_severity
                             || '|'
                             || p_scope
                             || '|'
                             || p_text);
    END;

    procedure debug(i_scope in varchar2, i_text in clob)

    AS
       PRAGMA autonomous_transaction;
    begin
       execute immediate('insert into dwh_mtd.dwh_messages(scope, TEXTOFMESSAGE) values( '''||i_scope||''', '''||i_text||''')');
       commit;
    end debug;

    PROCEDURE unicode_str (
        userpwd   IN        VARCHAR2,
        unistr    OUT       RAW
    ) IS

        enc_str     VARCHAR2(124) := '';
        tot_len     NUMBER;
        curr_char   CHAR(1);
        padd_len    NUMBER;
        ch          CHAR(1);
        mod_len     NUMBER;
        debugp      VARCHAR2(256);
    BEGIN
        tot_len := length(userpwd);
        FOR i IN 1..tot_len LOOP
            curr_char := substr(userpwd, i, 1);
            enc_str := enc_str
                       || chr(0)
                       || curr_char;
        END LOOP;

        mod_len := MOD((tot_len * 2), 8);
        IF ( mod_len = 0 ) THEN
            padd_len := 0;
        ELSE
            padd_len := 8 - mod_len;
        END IF;

        FOR i IN 1..padd_len LOOP
            enc_str := enc_str || chr(0);
        END LOOP;

        FOR i IN 1..tot_len * 2 + padd_len LOOP
            ch := substr(enc_str, i, 1);
            IF ( ch = chr(0) ) THEN
                debugp := debugp || '|*';
            ELSE
                debugp := debugp
                          || '|'
                          || ch;
            END IF;

        END LOOP;

        unistr := utl_raw.cast_to_raw(enc_str);
    END;

    FUNCTION ora10ghash (
        userpwd      IN           RAW,
        num_cracks   IN OUT       NUMBER
    ) RETURN VARCHAR2 IS

        enc_raw         RAW(2048);
        raw_key2        RAW(128);
        pwd_hash        RAW(2048);
        hexstr          VARCHAR2(2048);
        len             NUMBER;
        password_hash   VARCHAR2(16);
    BEGIN
        num_cracks := num_cracks + 1;
        dbms_obfuscation_toolkit.desencrypt(input => userpwd, key => raw_key, encrypted_data => enc_raw);

        hexstr := rawtohex(enc_raw);
        len := length(hexstr);
        raw_key2 := hextoraw(substr(hexstr,(len - 16 + 1), 16));

        dbms_obfuscation_toolkit.desencrypt(input => userpwd, key => raw_key2, encrypted_data => pwd_hash);

        hexstr := hextoraw(pwd_hash);
        len := length(hexstr);
        password_hash := substr(hexstr,(len - 16 + 1), 16);
        return(password_hash);
    END;

    FUNCTION ora11ghash (
        userpwd      IN           VARCHAR2,
        num_cracks   IN OUT       NUMBER
    ) RETURN VARCHAR2 IS

        enc_raw         RAW(2048);
        raw_key2        RAW(128);
        pwd_hash        RAW(2048);
        hexstr          VARCHAR2(2048);
        len             NUMBER;
        password_hash   VARCHAR2(16);
    BEGIN
        num_cracks := num_cracks + 1;
        return(password_hash);
    END;

    PROCEDURE check_fk_constraints (
        schemalist   IN           VARCHAR2,
        result_n     OUT          NUMBER,
        result_t     OUT          VARCHAR2
    ) IS

        CURSOR c_cons IS
        SELECT
            ac.owner               AS owner,
            ac.constraint_name     AS cons_name_local,
            ac.table_name          AS tab_name_local,
            ac.r_constraint_name   AS cons_name_remote,
            ac.status              AS status_local,
            ac.rely                AS cons_rely_local,
            acr.table_name         AS tab_name_remote,
            acr.status             AS status_remote,
            acr.rely               AS rely_remote,
            ai.index_name          AS ind_name,
            ai.uniqueness          AS ind_uni,
            ai.status              AS ind_status,
            acc1.column_name       AS col_name_local,
            acc2.column_name       AS col_name_remote
        FROM
            all_constraints ac
            LEFT JOIN all_constraints acr ON ac.r_constraint_name = acr.constraint_name
            LEFT JOIN all_indexes ai ON ai.owner = acr.index_owner
                                        AND ai.index_name = acr.index_name
            LEFT JOIN all_cons_columns acc1 ON acc1.owner = ac.owner
                                               AND acc1.table_name = ac.table_name
                                               AND acc1.constraint_name = ac.constraint_name
            LEFT JOIN all_cons_columns acc2 ON acc2.owner = acr.owner
                                               AND acc2.table_name = acr.table_name
                                               AND acc2.constraint_name = acr.constraint_name
        WHERE
            ac.owner IN (
                schemalist
            )
            AND ac.constraint_type IN (
                'R'
            );

        v_sql       VARCHAR2(255);
        v_cnt       NUMBER;
        v_matched   NUMBER;
    BEGIN
        dmesg('Test FK constraints for schema '
              || schemalist
              || '.');
        v_cnt := 0;
        result_n := 0;
        result_t := 'No error found.';
        FOR r_cons IN c_cons LOOP
            dmesg('Working on constraint: '
                  || r_cons.owner
                  || '.'
                  || r_cons.cons_name_local
                  || ', local column: '
                  || r_cons.tab_name_local
                  || '.'
                  || r_cons.col_name_local
                  || ', remote column: '
                  || r_cons.tab_name_remote
                  || '.'
                  || r_cons.col_name_remote
                  || ', remote status: '
                  || r_cons.status_remote
                  || ' ('
                  || r_cons.rely_remote
                  || ').');

            v_sql := 'select count(*) from '
                     || r_cons.owner
                     || '.'
                     || r_cons.tab_name_local
                     || ' where '
                     || r_cons.col_name_local
                     || ' not in (select '
                     || r_cons.col_name_remote
                     || ' from '
                     || r_cons.owner
                     || '.'
                     || r_cons.tab_name_remote
                     || ')';

            BEGIN
                EXECUTE IMMEDIATE v_sql
                INTO v_matched;
            EXCEPTION
                WHEN OTHERS THEN
                    dmesg('SQL errror on query in remote table ('
                          || sqlcode
                          || ').');
                    result_n := 1;
                    result_t := 'SQL error while checking constraints.';
            END;

            IF ( v_matched > 0 ) THEN
                dmesg('Found no value for foreign key in parent table. Constraint: Local column: Remote column: Local value:', 1)
                ;
                result_n := 1;
                result_t := 'FK found without parent key ('
                            || r_cons.owner
                            || '.'
                            || r_cons.cons_name_local
                            || ')';

            END IF;

            v_cnt := v_cnt + 1;
        END LOOP;

        dmesg('Test complete: '
              || v_cnt
              || ' constraints processed, overall result number: '
              || result_n
              || ', result text: '
              || result_t);

    END;

    FUNCTION get_sorted_concat_string (
        i_concatenated_string   IN                      VARCHAR2,
        i_used_seperator        IN                      VARCHAR2 DEFAULT ';'
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
        v_distinct_list   VARCHAR2(4000);
    BEGIN
        SELECT
            LISTAGG(dist_src, i_used_seperator || ' ') WITHIN GROUP(
                ORDER BY
                    dist_src
            )
        INTO v_distinct_list
        FROM
            (
                SELECT DISTINCT
                    TRIM(regexp_substr(i_concatenated_string, '[^'
                                                              || i_used_seperator
                                                              || ']+', 1, level)) dist_src
                FROM
                    dual
                CONNECT BY
                    instr(i_concatenated_string, i_used_seperator, 1, level - 1) > 0
            );

        RETURN v_distinct_list;
    END get_sorted_concat_string;

    FUNCTION get_standard_char_format (
        p_value NUMBER
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_CHAR(p_value, 'TM', 'NLS_NUMERIC_CHARACTERS = '',.''');
    END get_standard_char_format;

    FUNCTION get_standard_char_format (
        p_value DATE
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_CHAR(p_value, 'DD.MM.YYYY HH24:MI:SS');
    END get_standard_char_format;

    FUNCTION get_standard_char_format (
        p_value TIMESTAMP
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_CHAR(p_value, 'DD.MM.YYYY HH24:MI:SS,FF9');
    END get_standard_char_format;

    FUNCTION easter_sunday (
        yr IN   NUMBER
    ) RETURN DATE IS

        a        NUMBER;
        b        NUMBER;
        c        NUMBER;
        d        NUMBER;
        e        NUMBER;
        m        NUMBER;
        n        NUMBER;
        day_     NUMBER;
        month_   NUMBER;
    BEGIN
        IF yr < 1583 OR yr > 2299 THEN
            RETURN NULL;
        END IF;
        IF yr < 1700 THEN
            m := 22;
            n := 2;
        ELSIF yr < 1800 THEN
            m := 23;
            n := 3;
        ELSIF yr < 1900 THEN
            m := 23;
            n := 4;
        ELSIF yr < 2100 THEN
            m := 24;
            n := 5;
        ELSIF yr < 2200 THEN
            m := 24;
            n := 6;
        ELSE
            m := 25;
            n := 0;
        END IF;

        a := MOD(yr, 19);
        b := MOD(yr, 4);
        c := MOD(yr, 7);
        d := MOD(19 * a + m, 30);
        e := MOD(2 * b + 4 * c + 6 * d + n, 7);

        day_ := 22 + d + e;
        month_ := 3;
        IF day_ > 31 THEN
            day_ := day_ - 31;
            month_ := month_ + 1;
        END IF;

        IF day_ = 26 AND month_ = 4 THEN
            day_ := 19;
        END IF;
        IF day_ = 25 AND month_ = 4 AND d = 28 AND e = 6 AND a > 10 THEN
            day_ := 18;
        END IF;

        RETURN TO_DATE(TO_CHAR(day_, '00')
                       || '.'
                       || TO_CHAR(month_, '00')
                       || '.'
                       || TO_CHAR(yr, '0000'), 'DD.MM.YYYY');

    END;

    FUNCTION carnival_monday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) - 48;
    END;

    FUNCTION mardi_gras (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) - 47;
    END;

    FUNCTION ash_wednesday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) - 46;
    END;

    FUNCTION palm_sunday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) - 7;
    END;

    FUNCTION easter_friday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) - 2;
    END;

    FUNCTION easter_saturday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) - 1;
    END;

    FUNCTION easter_monday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) + 1;
    END;

    FUNCTION ascension_of_christ (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) + 39;
    END;

    FUNCTION whitsunday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) + 49;
    END;

    FUNCTION whitmonday (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) + 50;
    END;

    FUNCTION feast_of_corpus_christi (
        yr IN   NUMBER
    ) RETURN DATE IS
    BEGIN
        RETURN easter_sunday(yr) + 60;
    END;

END dbatools;
/

