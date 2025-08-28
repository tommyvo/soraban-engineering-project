import React, { useState, useEffect } from "react";
import ReactPaginate from 'react-paginate';

function RuleManager() {
  const FIELDS = ["description", "amount"];
  const OPERATORS = ["contains", ">", "<", "="];

  const [rules, setRules] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newRule, setNewRule] = useState({
    field: "description",
    operator: "contains",
    value: "",
    category: "",
    priority: 1
  });
  const [editingId, setEditingId] = useState(null);
  const [editRule, setEditRule] = useState({});
  const [status, setStatus] = useState(null);
  const [page, setPage] = useState(0); // 0-based for react-paginate
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    fetchRules();
    // eslint-disable-next-line
  }, [page]);

  async function fetchRules() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/v1/rules?page=${ page + 1 }`);
      if (!res.ok) throw new Error("Failed to fetch rules");
      const data = await res.json();
      setRules(data.rules || []);
      setTotalPages(data.total_pages || 1);
    } catch (e) {
      setError("Could not load rules");
    } finally {
      setLoading(false);
    }
  }

  function handleInput(e, setter) {
    const {name, value} = e.target;
    setter(r => ({...r, [name]: value}));
  }

  async function handleCreate(e) {
    e.preventDefault();
    setStatus(null);
    try {
      const res = await fetch("/api/v1/rules", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({rule: newRule})
      });
      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.errors?.join(", ") || "Create failed");
      }
      setNewRule({
        field: "description",
        operator: "contains",
        value: "",
        category: "",
        priority: 1
      });
      fetchRules();
      setStatus({success: "Rule created"});
    } catch (e) {
      setStatus({error: e.message});
    }
  }

  function startEdit(rule) {
    setEditingId(rule.id);
    setEditRule({...rule});
  }

  function cancelEdit() {
    setEditingId(null);
    setEditRule({});
  }

  async function handleEditSave(id) {
    setStatus(null);
    try {
      const res = await fetch(`/api/v1/rules/${ id }`, {
        method: "PATCH",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({rule: editRule})
      });
      if (!res.ok) {
        const data = await res.json();
        throw new Error(data.errors?.join(", ") || "Update failed");
      }
      setEditingId(null);
      setEditRule({});
      fetchRules();
      setStatus({success: "Rule updated"});
    } catch (e) {
      setStatus({error: e.message});
    }
  }

  async function handleDelete(id) {
    setStatus(null);
    if (!window.confirm("Delete this rule?")) return;
    try {
      const res = await fetch(`/api/v1/rules/${ id }`, {method: "DELETE"});
      if (!res.ok) throw new Error("Delete failed");
      fetchRules();
      setStatus({success: "Rule deleted"});
    } catch (e) {
      setStatus({error: e.message});
    }
  }

  if (loading) return <div>Loading rules...</div>;
  if (error) return <div style={ {color: "red"} }>{ error }</div>;

  return (
    <div style={ {maxWidth: 800, margin: "2rem auto"} }>
      { status?.success && <div
        style={ {color: 'green', marginBottom: 8} }>{ status.success }</div> }
      { status?.error &&
        <div style={ {color: 'red', marginBottom: 8} }>{ status.error }</div> }
      <table className="transaction-table"
        style={ {width: "100%", borderCollapse: "collapse"} }>
        <thead>
        <tr>
          <th>Field</th>
          <th>Operator</th>
          <th>Value</th>
          <th>Category</th>
          <th>Priority</th>
          <th></th>
        </tr>
        </thead>
        <tbody>
        { rules.map(rule => (
          <tr key={ rule.id }>
            { editingId === rule.id ? (
              <>
                <td>
                  <select name="field" value={ editRule.field }
                    onChange={ e => handleInput(e, setEditRule) }>
                    { FIELDS.map(f => <option key={ f }
                      value={ f }>{ f }</option>) }
                  </select>
                </td>
                <td>
                  <select name="operator" value={ editRule.operator }
                    onChange={ e => handleInput(e, setEditRule) }>
                    { OPERATORS.map(o => <option key={ o }
                      value={ o }>{ o }</option>) }
                  </select>
                </td>
                <td><input name="value" value={ editRule.value }
                  onChange={ e => handleInput(e, setEditRule) } required /></td>
                <td><input name="category" value={ editRule.category }
                  onChange={ e => handleInput(e, setEditRule) } required /></td>
                <td><input name="priority" type="number"
                  value={ editRule.priority }
                  onChange={ e => handleInput(e, setEditRule) } min={ 1 }
                  required style={ {width: 80} } /></td>
                <td>
                  <button onClick={ () => handleEditSave(rule.id) }
                    style={ {marginRight: 4} }>Save
                  </button>
                  <button onClick={ cancelEdit }>Cancel</button>
                </td>
              </>
            ) : (
              <>
                <td>{ rule.field }</td>
                <td>{ rule.operator }</td>
                <td>{ rule.value }</td>
                <td>{ rule.category }</td>
                <td>{ rule.priority }</td>
                <td>
                  <button onClick={ () => startEdit(rule) }
                    style={ {marginRight: 4} }>Edit
                  </button>
                  <button onClick={ () => handleDelete(rule.id) }>Delete
                  </button>
                </td>
              </>
            ) }
          </tr>
        )) }
        </tbody>
      </table>
      <div
        style={ {margin: '1rem 0', display: 'flex', justifyContent: 'center'} }>
        <ReactPaginate
          previousLabel={ " Prev" }
          nextLabel={ "Next " }
          breakLabel={ "..." }
          pageCount={ totalPages }
          marginPagesDisplayed={ 1 }
          pageRangeDisplayed={ 3 }
          onPageChange={ ({selected}) => setPage(selected) }
          forcePage={ page }
          containerClassName={ "pagination" }
          activeClassName={ "active" }
          disabledClassName={ "disabled" }
        />
      </div>
      <form onSubmit={ handleCreate } style={ {
        marginTop: 24,
        padding: 16,
        border: '1px solid #ccc',
        borderRadius: 8,
        display: 'flex',
        flexDirection: 'column',
        gap: 8,
        background: '#fafbfc'
      } }>
        <div style={ {display: 'flex', gap: 8, alignItems: 'flex-end'} }>
          <select name="field" value={ newRule.field }
            onChange={ e => handleInput(e, setNewRule) }>
            { FIELDS.map(f => <option key={ f } value={ f }>{ f }</option>) }
          </select>
          <select name="operator" value={ newRule.operator }
            onChange={ e => handleInput(e, setNewRule) }>
            { OPERATORS.map(o => <option key={ o } value={ o }>{ o }</option>) }
          </select>
          <input name="value" value={ newRule.value }
            onChange={ e => handleInput(e, setNewRule) } placeholder="Value"
            required />
          <input name="category" value={ newRule.category }
            onChange={ e => handleInput(e, setNewRule) } placeholder="Category"
            required />
          <input name="priority" type="number" value={ newRule.priority }
            onChange={ e => handleInput(e, setNewRule) } min={ 1 } required
            style={ {width: 80} } />
        </div>
        <button type="submit" style={ {alignSelf: 'flex-start'} }>Add Rule
        </button>
      </form>
    </div>
  );
}

export default RuleManager;
