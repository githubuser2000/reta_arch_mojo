from std.sys import argv
from std.collections import List
from reta_mojo.prompt_runtime_catalog import prompt_runtime_contract


def _print_ints(values: List[Int]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += String(values[index])
    return result^


def main() raises:
    var args = argv()
    if len(args) != 2:
        raise Error("usage: prompt_runtime_contract_probe LANGUAGE")
    var requested = String(args[1])
    var contract = prompt_runtime_contract(requested)
    print("@@@" + requested)
    print("class=" + contract.program.class_name)
    for index in range(len(contract.program.main_parameter_names)):
        print(
            "main=" + contract.program.main_parameter_names[index] + ":"
            + String(contract.program.main_parameter_indices[index])
        )
    print("para_n_data=" + String(contract.program.para_n_data_matrix_len))
    print("para_dict=" + String(contract.program.para_dict_len))
    print("data=" + _print_ints(contract.program.data_dict_sizes))
    print("kombi=" + String(contract.program.combination_reverse_len))
    print("kombi2=" + String(contract.program.combination_reverse2_len))
    print("simple=" + String(contract.program.simple_command_columns_len))
    print("max1024=" + String(contract.program.max_rows_1024))
    print("max114=" + String(contract.program.max_rows_114))
    print("main_parameters_len=" + String(contract.vocabulary.main_parameters_len))
    print("zeilen_paras_len=" + String(contract.vocabulary.row_parameters_len))
    print("ausgabe_paras_len=" + String(contract.vocabulary.output_parameters_len))
    print("ausgabe_art_len=" + String(contract.vocabulary.output_modes_len))
    print("kombi_main_paras_len=" + String(contract.vocabulary.combination_parameters_len))
    print("befehle2_len=" + String(contract.vocabulary.command_values_len))
    print("befehle_len=" + String(contract.vocabulary.commands_len))
    print("spalten_dict_keys=" + String(contract.vocabulary.column_dictionary_keys))
    print("spalten_len=" + String(contract.vocabulary.columns_len))
    print("gebrochen_erlaubte_zahlen_len=" + String(contract.vocabulary.fraction_allowed_numbers_len))
    print("haupt_for_neben_len=" + String(contract.vocabulary.main_for_sub_len))
    print("normal_prefix=" + contract.normal_prefix)
    print("store_prefix=" + contract.store_prefix)
    print("delete_prefix=" + contract.delete_prefix)
    print("wahl15=" + ("1" if contract.wahl15_valid else "0"))
    print("missing=" + String(len(contract.wahl15_missing_values)))
    for index in range(len(contract.wahl15_missing_values)):
        print("missing_value=[" + contract.wahl15_missing_values[index] + "]")
