# ("create": {
#         "create_as": [["create table", "as"], [";"]],
#         "create": [["create table"], [";"]]
#       }
#
# test = dict()
# test["create"] = dict()
# test["create"]["create_as"] = list()
# test["create"]["create"] = list()
# test_list_1 = ["create table", "as"]
# test["create"]["create_as"].append(test_list_1)
# test["create"]["create_as"].append([";"])
# test_list_2 = ["create table"]
# test["create"]["create"].append(test_list_2)
# test["create"]["create"].append([";"])
# print(test["create"]["create"])
#
# print(len(test["create"]["create"]))


line = "99292923--hello"
line = line[0:line.find('--')]
print(line)