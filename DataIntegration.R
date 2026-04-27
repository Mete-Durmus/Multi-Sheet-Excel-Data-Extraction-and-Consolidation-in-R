library(readxl)
library(stringi)
library(here)
library(tibble)

#=================================================================================
#                               Functions
#=================================================================================

#For pattern and name matching
normalize_character <- function(x) {
  # Ensure lowercase safely (preserve case if needed)
  x <- stri_trans_general(x, "NFC")
  x <- gsub("İ", "i", x)
  x <- gsub("I", "i", x)
  x <- gsub("ı", "i", x)
  x <- gsub("Ş", "s", x)
  x <- gsub("ş", "s", x)
  x <- gsub("Ğ", "g", x)
  x <- gsub("ğ", "g", x)
  x <- gsub("Ç", "c", x)
  x <- gsub("ç", "c", x)
  x <- gsub("Ö", "o", x)
  x <- gsub("ö", "o", x)
  x <- gsub("Ü", "u", x)
  x <- gsub("ü", "u", x)
  
  x <- tolower(x)
  return(x)
}

#To have the mappings for file paths and corresponding sheet names for each pattern
sheet_pattern_match <- function(path, #the folder path having all the excel files inside
                                pattern_list #list of patterns to search for excel files and sheets within them
                                ) {

  # Get paths all Excel files
  files <- list.files(path, pattern = "\\.xlsx$", full.names = TRUE) 
  
  #the mapping list
  sheet_matching_list <- list()
  
  for (file in files) { #for each excel file
    
    #Find the sheet names within the excel file
    sheets <- excel_sheets(file) 
  
    #Apply string standardization
    sheet_names_std <- normalize_character(sheets)
  
    #Within the file
    for (pattern in pattern_list){ #search for each pattern
      match_idx <- grep(pattern, sheet_names_std) #have the indexes in the standardized list
      
      
      if (length(sheets[match_idx]) > 0) { #If sheets found within file
        excel_name <- sub(".*/", "", file) #only the file name part for readability
        
        sheet_matching_list[[pattern]][[excel_name]] <- sheets[match_idx] #with the pattern name as key
                                                                          #the list that holds sheet names
                                                                          #and the excel name for the file as a key
      }
    }
  }
  return(sheet_matching_list)
}


variable_formulation <- function(connecting_data, #the data frame that all fragmented data is connected,
                                         #within the specific purpose of variables
                        fragmented_data, #each excel sheet in files
                        new_column_list = NULL,  #the new column in the connecting data to be generated
                        operation_list = NULL,  #the string variable that holds the manipulation of the variables
                                          #it needs to have the variable names in the fragmented data,
                                          #the mathematical operations
                                          #and white space as separator
                                          #e.g. "column1, mean" or "column1 * column2 / 2"
                        sheet = NULL, #the name of the sheet
                        sheet_name_column = "ID", #the sheet name variable in the data to index the place of the resulting operation
                        export_true = FALSE #if clean data needs to be imported within nested excel
) {
  
  #Handle errors
  
  #the length may not match between operations and column naming
  if (length(new_column_list) != length(operation_list)) {
    stop("new_column_list and operation_list must have the same length")
  } #better approach would be to have string matching on the list since the order also may not match
  
  #the list that has the result of each operations respectively
  result_list <- lapply(operation_list, function(operation_string){
    with(fragmented_data, eval(parse(text = operation_string)) )
  })
  
  #save the results column wise into the data
  current_rows <- connecting_data[[sheet_name_column]] == sheet
  index = 1
  
  connecting_data[current_rows, new_column_list] <- as.data.frame(result_list)

  return(connecting_data)
}



  
#=================================================================================
#                              Importing Data
#=================================================================================

folder_name <- "excel_files"
path <- here(folder_name) #folder path including excel files

#file_pattern names for sheet extraction
#These names used in excel file names and are the only pattern
file_pattern <- c("c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8")


#file paths and file_pattern names as name, sheet names inside the path as value
file_mapping <- sheet_pattern_match(path,
                                    file_pattern)


#initiate a data to save the results
data <- tibble(
  "ID" = unlist(file_mapping, use.names = FALSE)
)

#the column names that each data will have
col_names <- c("speaker", "speech", "child_directed", "causal_lexical", "causal_morphological", 
               "causal_conjunction", "token", "language_function", "language_function_numeric", 
               "counterfactual", "indicative", "questions")



for (pattern_name in names(file_mapping)) { #for each pattern
  files <- file_mapping[[pattern_name]] #save the file name lists
  
  for (file_name in names(files)){ #for each file name
    sheet_vector <- files[[file_name]] #save sheet vector
    
    path <- here(paste(folder_name, file_name, sep = "/")) #find the path
    
    cat("File", file_name, "is in process...\n", sep = " ")
    
    for (sheet in sheet_vector) { #for each sheet

      #export the data, by sheet
      suppressMessages(
        excel_data <- read_excel(path, sheet = sheet, 
                                 col_names = FALSE)
      )
        
      #find the first column index having the transcriptions
      matches <- sapply(excel_data, function(col) grepl("[*%]", as.character(col)))
      
      #it is a table in all sheets in the same length
      excel_data <- excel_data[, which.max(colSums(matches)) : length(col_names)]
      colnames(excel_data) <- col_names #then assign the column names
      
      excel_data <- excel_data[grepl("[*%]", excel_data$speaker),]

          
      #this variable holds 1 if the speech is not from child, it is directed to child
      child_data <- excel_data[excel_data$child_directed == 0, ]
          
      #apply operations and append it into the data
      data <- variable_formulation( connecting_data = data,
                                    fragmented_data = child_data,
                                    new_column_list =  c("lexical_child",
                                                         "morphological_child",
                                                         "conjunction_child",
                                                         "wordCount_child",
                                                         "wordType_child"),
                                    operation_list = c("sum(as.numeric(causal_lexical), na.rm = TRUE)",
                                                       "sum(as.numeric(causal_morphological), na.rm = TRUE)",
                                                       "sum(as.numeric(causal_conjunction), na.rm = TRUE)",
                                                       "sum(!is.na(token))",
                                                       "length(unique(token))"),
                                    sheet = sheet,
                                    sheet_name_column = "ID"                      
      )
        
      child_directed_data <- excel_data[excel_data$child_directed == 1, ]
          
      data <- variable_formulation( connecting_data = data,
                                    fragmented_data = child_directed_data,
                                    new_column_list =  c("lexical_childDirected",
                                                         "morphological_childDirected",
                                                         "conjunction_childDirected",
                                                         "wordCount_childDirected",
                                                         "wordType_childDirected"),
                                    operation_list = c("sum(as.numeric(causal_lexical), na.rm = TRUE)",
                                                       "sum(as.numeric(causal_morphological), na.rm = TRUE)",
                                                       "sum(as.numeric(causal_conjunction), na.rm = TRUE)",
                                                       "sum(!is.na(token))",
                                                       "length(unique(token))"),
                                    sheet = sheet,
                                    sheet_name_column = "ID"                      
      )
        
    }
  }
}



