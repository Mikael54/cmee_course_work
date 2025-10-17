taxa = [ ('Myotis lucifugus','Chiroptera'),
         ('Gerbillus henleyi','Rodentia',),
         ('Peromyscus crinitus', 'Rodentia'),
         ('Mus domesticus', 'Rodentia'),
         ('Cleithrionomys rutilus', 'Rodentia'),
         ('Microgale dobsoni', 'Afrosoricida'),
         ('Microgale talazaci', 'Afrosoricida'),
         ('Lyacon pictus', 'Carnivora'),
         ('Arctocephalus gazella', 'Carnivora'),
         ('Canis lupus', 'Carnivora'),
        ]

taxa_dic = {}

for species, order in taxa:
    if order in taxa_dic:
        taxa_dic[order].add(species)
    else:
        taxa_dic[order] = set([species])

print(taxa_dic)




# Now write a list comprehension that does the same (including the printing after the dictionary has been created)  
 
taxa_dic = {}

orders  = {order for species, order in taxa}

taxa_dic = {order: {species for species, order_2 in taxa if order_2 == order} for order in orders}
print(taxa_dic)