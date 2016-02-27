using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Linq.Expressions;

namespace ViewModel.Helpers
{
    public class ViewModelBase : INotifyPropertyChanged//,INotifyDataErrorInfo //NET 4.5 Support
    {
        #region Property changed
        public event PropertyChangedEventHandler PropertyChanged; // event handler for the property changed

        protected virtual void OnPropertyChanged(string propertyName)// the actual event called to trigger a notification of the property changed
        {
            if (this.PropertyChanged != null)
            {
                this.PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }
        protected void OnPropertyChanged<T>(Expression<Func<T>> selectorExpression) // lambda expression compatible onpropertychanged
        {
            if (selectorExpression == null) throw new ArgumentNullException("selectorExpression"); // check havent been given an empty expression!// throw error for empty expression
            MemberExpression body = selectorExpression.Body as MemberExpression; // convert external ref to a usable form
            if (body == null) throw new ArgumentException("The body must be a member expression"); // check the new conversion isn't empty// if the conversion is empty throw
            OnPropertyChanged(body.Member.Name); // actually trigger the property change event
        }
        public bool SetField<T>(ref T field, T value, Expression<Func<T>> selectorExpression) // internal ref, value in, external ref, this sets the value then calls the lambda compatible onproperty changed
        {
            if (EqualityComparer<T>.Default.Equals(field, value)) return false; // check if the same

            field = value; //set car to new value
            OnPropertyChanged(selectorExpression);

            //notify that property has changed note this is calling the selector expression, not the actual inotify
            return true;
        }
        #endregion
    }
}
