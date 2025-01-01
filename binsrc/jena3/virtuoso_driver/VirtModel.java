/*
 *  $Id:$
 *
 *  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
 *  project.
 *
 *  Copyright (C) 1998-2025 OpenLink Software
 *
 *  This project is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation; only version 2 of the License, dated June 1991.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 *
 */
package virtuoso.jena.driver;


import java.io.InputStream;
import java.io.Reader;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import javax.sql.*;

import org.apache.jena.query.ReadWrite;
import org.apache.jena.rdf.model.Statement;
import org.apache.jena.riot.system.StreamRDF;
import org.apache.jena.shared.*;
import org.apache.jena.rdf.model.*;
import org.apache.jena.rdf.model.impl.*;


public class VirtModel extends ModelCom {

    /**
     * @param base
     */
    public VirtModel(VirtGraph base) {
        super(base);
    }


    public static VirtModel openDefaultModel(ConnectionPoolDataSource ds) {
        return new VirtModel(new VirtGraph(ds));
    }

    public static VirtModel openDatabaseModel(String graphName,
                                              ConnectionPoolDataSource ds) {
        return new VirtModel(new VirtGraph(graphName, ds));
    }


    public static VirtModel openDefaultModel(DataSource ds) {
        return new VirtModel(new VirtGraph(ds));
    }

    public static VirtModel openDatabaseModel(String graphName,
                                              DataSource ds) {
        return new VirtModel(new VirtGraph(graphName, ds));
    }


    public static VirtModel openDefaultModel(String url, String user,
                                             String password) {
        return new VirtModel(new VirtGraph(url, user, password));
    }

    public static VirtModel openDatabaseModel(String graphName, String url,
                                              String user, String password) {
        return new VirtModel(new VirtGraph(graphName, url, user, password));
    }

    @Override
    public Model removeAll() {
        try {
            VirtGraph _graph = (VirtGraph) this.graph;
            _graph.clear();
        } catch (ClassCastException e) {
            super.removeAll();
        }
        return this;
    }


    public StreamRDF getStreamRDF(boolean useAutoCommit, int chunkSize, VirtStreamRDF.DeadLockHandler dhandler) {
        return new VirtStreamRDF(this, useAutoCommit, chunkSize, dhandler);
    }

    public void createRuleSet(String ruleSetName, String uriGraphRuleSet) {
        ((VirtGraph) this.graph).createRuleSet(ruleSetName, uriGraphRuleSet);
    }


    public void removeRuleSet(String ruleSetName, String uriGraphRuleSet) {
        ((VirtGraph) this.graph).removeRuleSet(ruleSetName, uriGraphRuleSet);
    }

    public void setRuleSet(String _ruleSet) {
        ((VirtGraph) this.graph).setRuleSet(_ruleSet);
    }

    public void setSameAs(boolean _sameAs) {
        ((VirtGraph) this.graph).setSameAs(_sameAs);
    }

    public void setMacroLib(String _macroLib) {
        ((VirtGraph) this.graph).setMacroLib(_macroLib);
    }


    public int getBatchSize() {
        return ((VirtGraph) this.graph).getBatchSize();
    }


    public void setBatchSize(int sz) {
        ((VirtGraph) this.graph).setBatchSize(sz);
    }


    public String getSparqlPrefix() {
        return ((VirtGraph) this.graph).getSparqlPrefix();
    }


    public void setSparqlPrefix(String val) {
        ((VirtGraph) this.graph).setSparqlPrefix(val);
    }

    /**
     * Get the insertBNodeAsURI state for connection
     */
    public boolean getInsertBNodeAsVirtuosoIRI() {
        return ((VirtGraph) this.graph).getInsertBNodeAsVirtuosoIRI();
    }


    /**
     * Set the insertBNodeAsURI state for connection(default false)
     *
     * @param v
     *        true - insert BNode as Virtuoso IRI
     *        false - insert BNode as Virtuoso Native BNode
     */
    public void setInsertBNodeAsVirtuosoIRI(boolean v) {
        ((VirtGraph) this.graph).setInsertBNodeAsVirtuosoIRI(v);
    }


    /**
     * Get the resetBNodesDictAfterCall state for connection
     */
    public boolean getResetBNodesDictAfterCall() {
        return ((VirtGraph) this.graph).getResetBNodesDictAfterCall();
    }

    /**
     * Set the resetBNodesDictAfterCall (reset server side BNodes Dictionary,
     * that is used for map between Jena Bnodes and Virtuoso BNodes, after each
     * add call). The default state for connection is false
     *
     * @param v
     *        true  - reset BNodes Dictionary after each add(add batch) call
     *        false - not reset BNode Dictionary after each add(add batch) call
     */
    public void setResetBNodesDictAfterCall(boolean v) {
        ((VirtGraph) this.graph).setResetBNodesDictAfterCall(v);
    }


    /**
     * Get the resetBNodesDictAfterCommit state for connection
     */
    public boolean getResetBNodesDictAfterCommit() {
        return ((VirtGraph) this.graph).getResetBNodesDictAfterCommit();
    }

    /**
     * Set the resetBNodesDictAfterCommit (reset server side BNodes Dictionary,
     * that is used for map between Jena Bnodes and Virtuoso BNodes,
     * after commit/rollback).
     * The default state for connection is true
     *
     * @param v
     *        true  - reset BNodes Dictionary after each commit/rollack
     *        false - not reset BNode Dictionary after each commit/rollback
     */
    public void setResetBNodesDictAfterCommit(boolean v) {
        ((VirtGraph) this.graph).setResetBNodesDictAfterCommit(v);
    }



    /**
     * Get the insertStringLiteralAsSimple state for connection
     */
    public boolean getInsertStringLiteralAsSimple() {
        return ((VirtGraph) this.graph).getInsertStringLiteralAsSimple();
    }

    /**
     * Set the insertStringLiteralAsSimple state for connection(default false)
     *
     * @param v
     *        true - insert String Literals as Simple Literals
     *        false - insert String Literals as is
     */
    public void setInsertStringLiteralAsSimple(boolean v) {
        ((VirtGraph) this.graph).setInsertStringLiteralAsSimple(v);
    }


    /**
     * Set the concurrency mode for Insert/Update/Delete operations and SPARUL queries
     *
     * @param mode
     *        Concurrency mode
     */
    public void setConcurrencyMode(int mode) throws JenaException
    {
        ((VirtGraph) this.graph).setConcurrencyMode(mode);
    }

    /**
     * Get the concurrency mode for Insert/Update/Delete operations and SPARUL queries
     *
     * @return concurrency mode
     */
    public int getConcurrencyMode() {
        return ((VirtGraph) this.graph).concurencyMode;
    }


    @Override
    public Model read(String url) {
        VirtGraph g = (VirtGraph)getGraph();
        synchronized (g.lck_add){
            try {
              g.startBatchAdd();
            } catch(Exception e) {
              throw new JenaException(e);
            }
            try{
              Model ret = super.read(url);
              return ret;
            } finally {
              try {
                g.stopBatchAdd();
              } catch(Exception e) {
                throw new JenaException(e);
              }
            }
        }
    }

    @Override
    public Model read(Reader reader, String base) {
        VirtGraph g = (VirtGraph)getGraph();
        synchronized (g.lck_add){
            try {
              g.startBatchAdd();
            } catch(Exception e) {
              throw new JenaException(e);
            }
            try{
              Model ret = super.read(reader, base);
              return ret;
            } finally {
              try {
                g.stopBatchAdd();
              } catch(Exception e) {
                throw new JenaException(e);
              }
            }
        }
    }

    @Override
    public Model read(InputStream reader, String base) {
        VirtGraph g = (VirtGraph)getGraph();
        synchronized (g.lck_add){
            try {
              g.startBatchAdd();
            } catch(Exception e) {
              throw new JenaException(e);
            }
            try{
              Model ret = super.read(reader, base);
              return ret;
            } finally {
              try {
                g.stopBatchAdd();
              } catch(Exception e) {
                throw new JenaException(e);
              }
            }
        }
    }

    @Override
    public Model read(String url, String lang) {
        VirtGraph g = (VirtGraph)getGraph();
        synchronized (g.lck_add){
            try {
              g.startBatchAdd();
            } catch(Exception e) {
              throw new JenaException(e);
            }
            try{
              Model ret = super.read(url, lang);
              return ret;
            } finally {
              try {
                g.stopBatchAdd();
              } catch(Exception e) {
                throw new JenaException(e);
              }
            }
        }
    }

    @Override
    public Model read(String url, String base, String lang) {
        VirtGraph g = (VirtGraph)getGraph();
        synchronized (g.lck_add){
            try {
              g.startBatchAdd();
            } catch(Exception e) {
              throw new JenaException(e);
            }
            try{
              Model ret = super.read(url, base, lang);
              return ret;
            } finally {
              try {
                g.stopBatchAdd();
              } catch(Exception e) {
                throw new JenaException(e);
              }
            }
        }
    }

    @Override
    public Model read(Reader reader, String base, String lang) {
        VirtGraph g = (VirtGraph)getGraph();
        synchronized (g.lck_add){
            try {
              g.startBatchAdd();
            } catch(Exception e) {
              throw new JenaException(e);
            }
            try{
              Model ret = super.read(reader, base, lang);
              return ret;
            } finally {
              try {
                g.stopBatchAdd();
              } catch(Exception e) {
                throw new JenaException(e);
              }
            }
        }
    }

    @Override
    public Model read(InputStream reader, String base, String lang) {
        VirtGraph g = (VirtGraph)getGraph();
        synchronized (g.lck_add){
            try {
              g.startBatchAdd();
            } catch(Exception e) {
              throw new JenaException(e);
            }
            try{
              Model ret = super.read(reader, base, lang);
              return ret;
            } finally {
              try {
                g.stopBatchAdd();
              } catch(Exception e) {
                throw new JenaException(e);
              }
            }
        }
    }


    public Model add(Statement[] statements) {
        return add(Arrays.asList(statements).iterator());
    }

    @Override
    public Model add(List<Statement> statements) {
        return add(statements.iterator());
    }

    @Override
    public Model add(StmtIterator iter) {
        return add((Iterator<Statement>) iter);
    }

    protected Model add(Iterator<Statement> it) {
        VirtGraph g = (VirtGraph) this.graph;
        g.add(g.getGraphName(), it);
        return this;
    }

    @Override
    public Model add(Model m) {
        return add(m.listStatements());
    }


    @Override
    public Model remove(Statement[] statements) {
        return remove(Arrays.asList(statements).iterator());
    }

    @Override
    public Model remove(List<Statement> statements) {
        return remove(statements.iterator());
    }

    protected Model remove(Iterator<Statement> it) {
        VirtGraph g = (VirtGraph) this.graph;
        g.delete(g.getGraphName(), it);
        return this;
    }

    @Override
    public Model remove(Model m)
    {
        VirtGraph g = (VirtGraph) this.graph;
        g.md_delete_Model(m.listStatements());
        return this;
    }


    /** Begin a new transation.
     *
     * @param readWrite
     *        READ  - start transaction with default Concurrency mode
     *        WRITE - start transaction with Pessimistic Concurrency mode
     *
     * <p> All changes made to a model within a transaction, will either
     * be made, or none of them will be made.</p>
     * @return this model to enable cascading.

     */
    public Model begin(ReadWrite readWrite)
    {
        ((VirtGraph)getGraph()).getTransactionHandler().begin(readWrite);
        return this;
    }


}
