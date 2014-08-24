library(shiny)
library(plyr)
library(ggplot2)
library(scales)

# ######################
# FUNCION roi
# ######################
# Parámetros
# ==========
# numEst: número de estudiantes matriculados
# credPrim: número total de créditos en primera matrícula
# credPos: número total de cŕeditos en segunda o posteriores matrículas
# precPrim: precio por crédito en primera matrícula
# precPos: precio por crédito en segunda o posteriores matrículas
# porcAb: porcentaje de abandono anual
# sens: sensibilidad del modelo predictivo
# porcFP: porcentaje de falsos positivos (respecto a verdaderos negativos) del modelo predictivo
# costeAcc: coste anual en euros de una acción de retención.
# efAcc: porcentaje de efectividad de las acciones de retención
# costeMod: coste anual del modelo predictivo
#
# Salida
# ======
# Dataframe de un registro con la siguiente estructura:
#
# credPrimEst: número medio de créditos en primera matrícula por estudiante
# credPosEst: número medio de créditos en segunda y posteriores matrículas por estudiante
# ingrEst: ingresos medios por estudiante y año
# abandonosBase: número de abandonos si no se hace nada
# numEstRet: número de estudiantes que se retendrán
# ingrAdicBrutos: ingresos adicionales debido a los estudiantes retenidos
# verdPos: verdaderos positivos
# falsPos: falsos positivos
# numAcc: número de acciones disparadas (= número de abandono predichos)
# costeTotAcc: coste total de disparar las acciones
# ingrAdicNetos: ingresos adicionales netos debido a los estudiantes retenidos (tras restar los costes de las acc. de retención)

roi <- function(numEst=2696, credPrim=67465, credPos=7496, precPrim=75, precPos=37.5, porcAb=30, sens=70, porcFP=20, costeAcc=5, efAcc=5, costeMod=15000)
{

  #Do calculations
  credPrimEst <- credPrim/numEst
  credPosEst <- credPos/numEst
  ingrEst <- credPrimEst * precPrim + credPosEst * precPos
  abandonosBase <- round(numEst * porcAb/100)
  numEstRet <- round(abandonosBase * sens/100 * efAcc/100)
  ingrAdicBrutos <- numEstRet * ingrEst
  verdPos <- round(abandonosBase * sens/100)
  falsPos <- round((numEst - abandonosBase)*porcFP/100)
  numAcc <- verdPos + falsPos
  costeTotAcc <- numAcc * costeAcc
  ingrAdicNetos <- ingrAdicBrutos - costeTotAcc - costeMod
  
  resultado <- data.frame(
    "numEst"=numEst,
    "credPrim"=credPrim,
    "credPos"=credPos,
    "precPrim"=precPrim,
    "precPos"=precPos,
    "porcAb"=porcAb,
    "sens"=sens,
    "porcFP"=porcFP,
    "costeAcc"=costeAcc,
    "costeMod"=costeMod,
    "efAcc"=efAcc,
    "credPrimEst"=credPrimEst,
    "credPosEst"=credPosEst,
    "ingrEst"=ingrEst,
    "abandonosBase"= abandonosBase,
    "numEstRet"= numEstRet,
    "ingrAdicBrutos"=ingrAdicBrutos,
    "verdPos"=verdPos,
    "falsPos"=falsPos,
    "numAcc"= numAcc,
    "costeTotAcc"= costeTotAcc,
    "ingrAdicNetos"= ingrAdicNetos)
  
  resultado         
}

proyectaEfAcc <- function(l,numEst=2696, credPrim=67465, credPos=7496, precPrim=75, precPos=37.5, porcAb=30, sens=70, porcFP=20, costeAcc=5, costeMod=15000){
  ldply(l,function(e){roi(numEst=numEst, credPrim=credPrim, credPos=credPos, precPrim=precPrim, precPos=precPos, porcAb=porcAb, sens=sens, porcFP=porcFP, costeAcc=costeAcc, efAcc=e, costeMod=costeMod)})
}

proyectaSens <- function(l,numEst=2696, credPrim=67465, credPos=7496, precPrim=75, precPos=37.5, porcAb=30, porcFP=20, costeAcc=5, efAcc=5, costeMod=15000){
  ldply(l,function(s){roi(numEst=numEst, credPrim=credPrim, credPos=credPos, precPrim=precPrim, precPos=precPos, porcAb=porcAb, sens=s, porcFP=porcFP, costeAcc=costeAcc, efAcc=efAcc, costeMod=costeMod)})
}

#Vector to use in projections
l <- 1:100

# Define server logic
shinyServer(function(input, output) {
  
    output$texto1<-renderText({
    res <- roi(input$numEst, input$credPrim, input$credPos, input$precPrim, input$precPos, input$porcAb, input$sens, input$porcFP, input$costeAcc, input$efAcc, input$costeMod)
    paste("From ",
          res[1,]$numEst,
          "enrolled students, ",
          res[1,]$abandonosBase,
          " would dropout the next year. The system would generate ",
          res[1,]$numAcc,
          " dropout risk alerts,",
          res[1,]$verdPos,
          " would be true alerts, and ",
          res[1,]$falsPos,
          " would be false alarms. ",
          res[1,]$numAcc,
          " retention actions would be triggered, with a total cost of ",
          res[1,]$costeTotAcc,
          " €. As a result, ",
          res[1,]$numEstRet,
          " students would be retained, generating next year a gross revenue of ",
          round(res[1,]$ingrAdicBrutos,2),
          " € and a net income of ",
          round(res[1,]$ingrAdicNetos,2),
          " € (that is: after substracting the cost of retention actions ant the cost of the predictive system)."
          )
  })
  
  output$plot1 <- renderPlot({
    proySens <- proyectaSens(l, input$numEst, input$credPrim, input$credPos, input$precPrim, input$precPos, input$porcAb, input$porcFP, input$costeAcc, input$efAcc, input$costeMod)
    g <- ggplot(data=proySens, aes(x=sens, y=ingrAdicNetos)) +
      geom_line() +
      geom_vline(xintercept = input$sens,  colour="green", linetype = "longdash") + 
      xlab("Model sensitivity (%)") +
      ylab("ROI (€)") +
      scale_y_continuous(labels=comma) +
      ggtitle("Model sensitivity vs. ROI")
    g
  })
  
  output$plot2 <- renderPlot({
    proyEfAcc <- proyectaEfAcc(l, input$numEst, input$credPrim, input$credPos, input$precPrim, input$precPos, input$porcAb, input$sens, input$porcFP, input$costeAcc, input$costeMod)
    g <- ggplot(data=proyEfAcc, aes(x=efAcc, y=ingrAdicNetos)) +
      geom_line() +
      geom_vline(xintercept = input$efAcc,  colour="green", linetype = "longdash") + 
      xlab("Effectiveness of retention actions (%)") + 
      ylab("ROI (€)") +
      scale_y_continuous(labels=comma) +
      ggtitle("Retention effectiveness vs. ROI")
    g
  })  

})